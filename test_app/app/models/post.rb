# frozen_string_literal: true

class Post < ApplicationRecord
  extend Mobility
  translates :title, plain: true
  translates :content

  has_rich_text :non_i18n_content
end
