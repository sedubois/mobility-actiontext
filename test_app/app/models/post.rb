# frozen_string_literal: true

class Post < ApplicationRecord
  extend Mobility
  translates :title, plain: true
  translates :content
end
