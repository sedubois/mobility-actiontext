# frozen_string_literal: true

require 'test_helper'

module Mobility
  class ActionTextTest < ActiveSupport::TestCase
    test 'post title backend is Mobility::Backends::ActionText' do
      post = posts(:one)

      assert_kind_of Mobility::Backends::ActionText, post.title_backend
    end

    test 'post content backend is Mobility::Backends::ActionText' do
      post = posts(:one)

      assert_kind_of Mobility::Backends::ActionText, post.content_backend
    end

    test 'post has plain_text_translations association' do
      post = posts(:one)

      assert post.plain_text_translations
    end

    test 'post has rich_text_translations association' do
      post = posts(:one)

      assert post.rich_text_translations
    end

    test 'post has two plain text translations' do
      post = posts(:one)

      assert_equal 2, post.plain_text_translations.count
    end

    test 'post has two rich text translations' do
      post = posts(:one)

      assert_equal 2, post.rich_text_translations.count
    end

    test 'post has plain text title' do
      post = posts(:one)

      assert_equal 'Post Title', post.title
    end

    test 'post has rich text content' do
      post = posts(:one)

      assert_instance_of Mobility::Backends::ActionText::RichTextTranslation, post.rich_text_content
      assert_equal <<~HTML, post.content.to_s
        <div class="trix-content">
          <h1>Hello world!</h1>
        </div>
      HTML
    end

    test 'post has different content in different languages' do
      post = posts(:one)

      I18n.with_locale(:en) do
        assert_equal 'Post Title', post.title
        assert_equal <<~HTML, post.content.to_s
          <div class="trix-content">
            <h1>Hello world!</h1>
          </div>
        HTML
      end
      I18n.with_locale(:fr) do
        assert_equal 'Le titre du billet', post.title
        assert_equal <<~HTML, post.content.to_s
          <div class="trix-content">
            <h1>Bonjour le monde !</h1>
          </div>
        HTML
      end
    end

    test 'post has no content when switching to untranslated language' do
      post = posts(:untranslated)

      I18n.with_locale(:en) do
        assert_equal 'untranslated title', post.title
        assert_equal <<~HTML, post.content.to_s
          <div class="trix-content">
            untranslated content
          </div>
        HTML
      end
      I18n.with_locale(:fr) do
        assert_not post.title?
        assert_not post.content?
      end
    end

    test 'post content is eager loaded explicitly' do
      post = assert_queries(2) { Post.with_rich_text_content.last }

      assert_no_queries do
        assert_equal 'Hello world!', post.content.to_plain_text

        skip('FIXME: this should execute no queries')
      end
    end

    test 'post content is eager loaded with all rich text' do
      post = assert_queries(2) { Post.with_all_rich_text.last }

      assert_no_queries do
        assert_equal 'Hello world!', post.content.to_plain_text
      end
    end

    test 'post non_i18n_content is eager loaded with all rich text' do
      post = assert_queries(2) { Post.with_all_rich_text.last }

      assert_no_queries do
        assert_equal 'Hello non i18n world!', post.non_i18n_content.to_plain_text
      end
    end

    test 'post is being destroyed' do
      assert_difference ->{Mobility::Backends::ActionText::RichTextTranslation.count}, -5 do
        assert posts(:one).destroy
      end
    end
  end
end
