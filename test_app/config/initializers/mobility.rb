# frozen_string_literal: true

Mobility.configure do |config|
  config.plugins do
    backend :action_text
    active_record
    reader
    writer
    backend_reader
    query
    cache
    dirty
    presence
  end
end
