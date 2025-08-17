# frozen_string_literal: true

require 'active_record'

# Configure database. This could use env variables to setup different adapters, but let's keep it simple.
database_config = {
  adapter: 'sqlite3',
  database: File.expand_path("../db/#{ENV.fetch('RACK_ENV', nil)}.sqlite3", __dir__),
  pool: 5,
  timeout: 5000
}

# Establish ActiveRecord connection
ActiveRecord::Base.establish_connection(database_config)

# Configure ActiveRecord logger
ActiveRecord::Base.logger = Logger.new($stdout) if ENV['RACK_ENV'] == 'development'
