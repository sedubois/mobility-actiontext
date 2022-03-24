# Mobility Action Text

![Gem Version](https://badge.fury.io/rb/mobility-actiontext.svg)
![Build Status](https://github.com/sedubois/mobility-actiontext/workflows/CI/badge.svg)

Translate Rails [Action Text](https://guides.rubyonrails.org/action_text_overview.html) rich text with [Mobility](https://github.com/shioyama/mobility).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mobility-actiontext'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mobility-actiontext

Make sure that Action Text is [installed](https://guides.rubyonrails.org/action_text_overview.html#installation), then run this migration:

```rb
class TranslateRichTexts < ActiveRecord::Migration[6.1]
  def change
    # or null: true to allow untranslated rich text
    add_column :action_text_rich_texts, :locale, :string, null: false

    remove_index :action_text_rich_texts,
                 column: [:record_type, :record_id, :name],
                 name: :index_action_text_rich_texts_uniqueness,
                 unique: true
    add_index :action_text_rich_texts,
              [:record_type, :record_id, :name, :locale],
              name: :index_action_text_rich_texts_uniqueness,
              unique: true
  end
end
```

## Usage

```diff
# app/models/message.rb
class Message < ApplicationRecord
+  extend Mobility
+
-  has_rich_text :content
+  translates :content, backend: :action_text
end
```

### Plain text

Although the main purpose of the `action_text_rich_texts` table is to store rich text, this gem allows using it for plain text as well. This could be useful to consolidate all text in a single table and to remove the need to migrate data when converting between one and the other.

```diff
# app/models/message.rb
class Message < ApplicationRecord
   extend Mobility

+  translates :title, backend: :action_text, plain: true
   translates :content, backend: :action_text
end
```

## Implementation note

Action Text's rich text content is saved in its own model that can be associated with any existing Active Record model using a polymorphic relation. Likewise, Mobility's KeyValue backend allows to translate any model using a polymorphic relation. This gem makes use of this similarity by combining both features in a single step, thus offering rich text "for free", i.e. in theory at no extra performance cost compared to untranslated rich text or translated plain text.

This is done through the `Mobility::Backends::ActionText::Translation` model extending `ActionText::RichText`. This model is backed by Action Text's existing `action_text_rich_texts` table and its existing `name`, `body` and `record` attributes, to which is added a new `locale` attribute.

[Read more](https://github.com/shioyama/mobility/issues/385) on the genesis of this gem.

## Development

After checking out the repo, run `bundle install` to install dependencies.

Execute tests by running:

```sh
cd test_app
bundle install
bundle exec rails test
```

To release a new version, update `lib/mobility/action_text/version.rb` and `CHANGELOG.md`, run `bundle && cd test_app && bundle`, commit, then run `bundle exec rake release`. This will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sedubois/mobility-actiontext.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
