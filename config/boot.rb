# frozen_string_literal: true

# Set default environment
ENV['RACK_ENV'] ||= 'development'

# Require bundler and the gems listed in Gemfile
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# Load environment variables
Dotenv.load

# Setup Zeitwerk autoloader
require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('../app', __dir__))

# Configure collapse to avoid namespace prefixes for top-level directories
loader.collapse(File.expand_path('../app/controllers', __dir__))
loader.collapse(File.expand_path('../app/models', __dir__))
loader.collapse(File.expand_path('../app/middlewares', __dir__))
loader.collapse(File.expand_path('../app/services', __dir__))

# Configure namespace mappings for nested modules
loader.inflector.inflect(
  'jwt_auth' => 'JWTAuth',
  'json_validator' => 'JSONValidator'
)

# Setup the autoloader
loader.setup

# Enable eager loading in test environment to catch issues early
loader.eager_load if ENV['RACK_ENV'] == 'test'
