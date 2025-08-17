# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../config/boot'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Rack::Test::Methods

  # Wrap each test in a database transaction that gets rolled back so we keep the database clean
  # between different test runs. Normally in Rails you would use the use_transactional_fixtures option for this.
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  # Define the app method for Rack::Test
  def app
    App.new
  end
end
