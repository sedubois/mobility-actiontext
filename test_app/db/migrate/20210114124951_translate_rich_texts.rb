# frozen_string_literal: true

class TranslateRichTexts < ActiveRecord::Migration[6.1]
  def change
    # or null: true to allow untranslated rich text
    add_column :action_text_rich_texts, :locale, :string, null: true

    remove_index :action_text_rich_texts,
                 column: %i[record_type record_id name],
                 name: :index_action_text_rich_texts_uniqueness,
                 unique: true
    add_index :action_text_rich_texts,
              %i[record_type record_id name locale],
              name: :index_action_text_rich_texts_uniqueness,
              unique: true
  end
end
