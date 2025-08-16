# frozen_string_literal: true

# Require the gems listed in Gemfile
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

# Load environment variables
Dotenv.load

# Require application files in dependency order
require_relative '../app/models/user'
require_relative '../app/models/user_store'
require_relative '../app/models/product'
require_relative '../app/models/product_store'

require_relative '../app/services/auth_strategies/base_strategy'
require_relative '../app/services/auth_strategies/jwt_auth'
require_relative '../app/services/auth_service'
require_relative '../app/services/response_handler'
require_relative '../app/services/static_file_server'
require_relative '../app/services/products/create_service'

require_relative '../app/middlewares/json_validator'
require_relative '../app/middlewares/auth_middleware'

require_relative '../app/controllers/auth_controller'
require_relative '../app/controllers/products_controller'
