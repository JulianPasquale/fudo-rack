# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../config/boot'
require 'sidekiq/testing'
require 'rspec-sidekiq'
require 'shoulda-matchers'

# Configure shoulda-matchers
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
  end
end

# Suppress Sidekiq logs during testing
Sidekiq.configure_client do |config|
  config.logger = nil
end

# Configure Sidekiq for testing
Sidekiq::Testing.fake!

RSpec::Sidekiq.configure do |config|
  # Clears all job queues before each example
  config.clear_all_enqueued_jobs = true # default => true

  # Whether to use terminal colours when outputting messages
  config.enable_terminal_colours = true # default => true

  # Warn when jobs are not enqueued to Redis but to a job array
  config.warn_when_jobs_not_processed_by_sidekiq = false
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model

  # Configure FactoryBot
  config.before(:suite) do
    FactoryBot.find_definitions
  end


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
