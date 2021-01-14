# frozen_string_literal: true

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'post has trix content' do
    post = Post.create!(content: '<h1>hello world!</h1>')

    assert_equal <<~HTML, post.content.to_s
      <div class="trix-content">
        <h1>hello world!</h1>
      </div>
    HTML
  end

  test 'post has no content when switching language' do
    post = Post.create!(content: '<h1>hello world!</h1>')

    I18n.with_locale(:fr) do
      assert_not post.content?
    end
  end
end
