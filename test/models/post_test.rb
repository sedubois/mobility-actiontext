# frozen_string_literal: true

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'post content backend is Mobility::Backends::ActionText' do
    post = posts(:one)

    assert_kind_of Mobility::Backends::ActionText, post.content_backend
  end

  test 'post has rich_text_content' do
    post = posts(:one)

    assert_instance_of Mobility::Backends::ActionText::Translation, post.rich_text_content
  end

  test 'post has content' do
    post = posts(:one)

    assert_equal <<~HTML, post.content.to_s
      <div class="trix-content">
        <h1>hello world!</h1>
      </div>
    HTML
  end

  test 'post content is eager loaded' do
    post = assert_queries(2) { Post.with_rich_text_content.last }

    assert_no_queries do
      assert_equal 'hello world!', post.content.to_plain_text

      skip('FIXME: this should execute no queries')
    end
  end

  test 'post has no content when switching language' do
    post = posts(:one)

    I18n.with_locale(:fr) do
      assert_not post.content?
    end
  end
end
