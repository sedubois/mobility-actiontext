ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def assert_queries(expected_count)
    ActiveRecord::Base.connection.materialize_transactions

    queries = []
    ActiveSupport::Notifications.subscribe("sql.active_record") do |*, payload|
      queries << payload[:sql] unless %w[ SCHEMA TRANSACTION ].include?(payload[:name])
    end

    yield.tap do
      assert_equal expected_count, queries.size, "#{queries.size} instead of #{expected_count} queries were executed. #{queries.inspect}"
    end
  end

  def assert_no_queries(&block)
    assert_queries(0, &block)
  end
end
