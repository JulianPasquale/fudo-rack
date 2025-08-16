# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../config/boot'
require_relative '../app'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Rack::Test::Methods

  # Clear the singleton instances before each test
  config.before(:each) do
    if ProductStore.instance_variable_defined?(:@singleton__instance__)
      ProductStore.remove_instance_variable(:@singleton__instance__)
    end
    if UserStore.instance_variable_defined?(:@singleton__instance__)
      UserStore.remove_instance_variable(:@singleton__instance__)
    end
  end

  # Define the app method for Rack::Test
  def app
    App.new
  end
end
