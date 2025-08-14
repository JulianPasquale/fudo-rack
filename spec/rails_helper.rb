# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'json'

# Require application files
require_relative '../app'
require_relative '../app/models/product'
require_relative '../app/models/product_store'
require_relative '../app/controllers/auth_controller'
require_relative '../app/controllers/products_controller'
require_relative '../app/middlewares/auth_middleware'
require_relative '../app/services/static_file_server'

RSpec.configure do |config|
  config.include Rack::Test::Methods

  # Clear the singleton instance before each test
  config.before(:each) do
    if ProductStore.instance_variable_defined?(:@singleton__instance__)
      ProductStore.remove_instance_variable(:@singleton__instance__)
    end
  end

  # Define the app method for Rack::Test
  def app
    App.new
  end
end