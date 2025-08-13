# frozen_string_literal: true

require 'rack/test'
require 'rack/builder'
require 'json'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

def app
  @app ||= begin
    result = Rack::Builder.parse_file(File.expand_path('../config.ru', __dir__))
    result.is_a?(Array) ? result[0] : result
  end
end