# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("..Gemfile", Pathname.new(__FILE__).realpath)
require_relative '../config/environment'
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
