# frozen_string_literal: true

require 'mobility/backends/active_record/key_value'

module Mobility
  # -
  module Backends
    #
    # Implements the {Mobility::Backends::KeyValue} backend for ActionText.
    #
    # @example
    #   class Post < ApplicationRecord
    #     extend Mobility
    #     translates :content, backend: :action_text
    #   end
    #
    #   post = Post.create(content: "<h1>My text is rich</h1>")
    #   post.rich_text_translations
    #   #=> #<ActionText::RichText::ActiveRecord_Associations_CollectionProxy ... >
    #   post.rich_text_translations.first.to_s
    #   #=> "<div class=\"trix-content\">\n  <h1>My text is rich</h1>\n</div>\n"
    #   post.content
    #   #=> "<div class=\"trix-content\">\n  <h1>My text is rich</h1>\n</div>\n"
    #   post.rich_text_translations.first.class
    #   #=> Mobility::Backends::ActionText::RichTextTranslation
    #
    class ActionText < ActiveRecord::KeyValue
      # override to return record instead of value
      def read(locale, **options)
        return super if self.options[:plain]

        if model.association_cached?("rich_text_#{attribute}")
          eager_loaded = model.public_send("rich_text_#{attribute}")
          return eager_loaded if eager_loaded.locale == locale.to_s
        end

        translation_for(locale, **options)
      end

      class << self
        def valid_keys
          super.tap { |keys| keys.delete(:type) } << :plain
        end

        # @!group Backend Configuration
        # @option (see Mobility::Backends::KeyValue::ClassMethods#configure)
        def configure(options)
          options[:plain] = false unless options.has_key?(:plain)
          if options[:plain]
            options[:association_name] ||= 'plain_text_translations'
            options[:class_name]       ||= PlainTextTranslation
          else
            options[:association_name] ||= 'rich_text_translations'
            options[:class_name]       ||= RichTextTranslation
          end
          options[:key_column]       ||= :name
          options[:value_column]     ||= :body
          options[:belongs_to]       ||= :record
          super
        end
        # @!endgroup

        # override destroy logic because we are not using the db tables from
        # the subclassed KeyValue implementation
        def define_after_destroy_callback(klass)
          # Ensure we only call after destroy hook once per translations class
          b = self
          translation_classes = [class_name, RichTextTranslation, PlainTextTranslation].uniq
          klass.after_destroy do
            @mobility_after_destroy_translation_classes = [] unless defined?(@mobility_after_destroy_translation_classes)
            (translation_classes - @mobility_after_destroy_translation_classes).each do |translation_class|
              translation_class.where(b.belongs_to => self).destroy_all
            end
            @mobility_after_destroy_translation_classes += translation_classes
          end
        end
      end

      setup do |attributes, options|
        next if options[:plain]

        attributes.each do |name|
          has_one :"rich_text_#{name}", -> { where(name: name, locale: Mobility.locale) },
                  class_name: 'Mobility::Backends::ActionText::RichTextTranslation',
                  as: :record, inverse_of: :record, autosave: true, dependent: :destroy
          Mobility.available_locales.each do |locale|
            has_one :"rich_text_#{name}_#{locale}", -> { where(name: name, locale: locale) },
                    class_name: 'Mobility::Backends::ActionText::RichTextTranslation',
                    as: :record, inverse_of: :record, autosave: true, dependent: :destroy
          end
          scope :"with_rich_text_#{name}", -> { includes("rich_text_#{name}") }
          scope :"with_rich_text_#{name}_and_embeds",
                -> { includes("rich_text_#{name}": { embeds_attachments: :blob }) }
        end

        singleton_class.prepend(WithAllRichText) unless singleton_class < WithAllRichText
      end

      module WithAllRichText
        def with_all_rich_text
          super.eager_load(:rich_text_translations)
        end
      end

      module ActionTextValidations
        extend ActiveSupport::Concern

        included do
          validates :name,
                    presence: true,
                    uniqueness: { scope: %i[record_id record_type locale], case_sensitive: true }
          validates :record, presence: true
          validates :locale, presence: true
        end
      end

      # Model for translated rich text
      class RichTextTranslation < ::ActionText::RichText
        extend ActionTextValidations
      end

      # Model for translated plain text
      class PlainTextTranslation < ::ActiveRecord::Base
        self.table_name = "action_text_rich_texts"

        belongs_to :record, polymorphic: true, touch: true

        extend ActionTextValidations
      end
    end

    register_backend(:action_text, ActionText)
  end
end
