# frozen_string_literal: true

require_relative 'lib/mobility/action_text/version'

Gem::Specification.new do |spec|
  spec.name          = 'mobility-actiontext'
  spec.version       = Mobility::ActionText::VERSION
  spec.authors       = ['Sébastien Dubois']
  spec.email         = ['sedubois@users.noreply.github.com']

  spec.summary       = 'Translate Rails Action Text rich text with Mobility.'
  spec.homepage      = 'https://github.com/sedubois/mobility-actiontext'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/sedubois/mobility-actiontext'
  spec.metadata['changelog_uri'] = 'https://github.com/sedubois/mobility-actiontext/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'mobility', '~> 1.1'
  spec.add_dependency 'rails', '~> 6.0'

  spec.add_development_dependency 'sqlite3', '~> 1.4'
end
