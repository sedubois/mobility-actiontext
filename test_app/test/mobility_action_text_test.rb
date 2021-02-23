# frozen_string_literal: true

require 'test_helper'

module Mobility
  class ActionTextTest < ActiveSupport::TestCase
    test 'post content backend is Mobility::Backends::ActionText' do
      post = posts(:one)

      assert_kind_of Mobility::Backends::ActionText, post.content_backend
    end

    test 'post has rich_text_translations association' do
      post = posts(:one)

      assert post.rich_text_translations
    end

    test 'post has two translations' do
      post = posts(:one)

      assert_equal 2, post.rich_text_translations.count
    end

    test 'post has rich_text_content' do
      post = posts(:one)

      assert_instance_of Mobility::Backends::ActionText::Translation, post.rich_text_content
    end

    test 'post has content' do
      post = posts(:one)

      assert_equal <<~HTML, post.content.to_s
        <div class="trix-content">
          <h1>Hello world!</h1>
        </div>
      HTML
    end

    test 'post has different content in different languages' do
      post = posts(:one)

      I18n.with_locale(:en) do
        assert_equal <<~HTML, post.content.to_s
          <div class="trix-content">
            <h1>Hello world!</h1>
          </div>
        HTML
      end
      I18n.with_locale(:fr) do
        assert_equal <<~HTML, post.content.to_s
          <div class="trix-content">
            <h1>Bonjour le monde !</h1>
          </div>
        HTML
      end
    end

    test 'post has no content when switching to untranslated language' do
      post = posts(:untranslated)

      I18n.with_locale(:fr) do
        assert_not post.content?
      end
    end

    test 'post content is eager loaded' do
      post = assert_queries(2) { Post.with_rich_text_content.last }

      assert_no_queries do
        assert_equal 'Hello world!', post.content.to_plain_text

        skip('FIXME: this should execute no queries')
      end
    end
  end
end
