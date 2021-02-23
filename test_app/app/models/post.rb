# frozen_string_literal: true

class Post < ApplicationRecord
  extend Mobility
  translates :content
end
