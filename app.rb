# frozen_string_literal: true

require 'rack/deflater'

# Require the gems listed in Gemfile
Bundler.require(:default, :development, :test)

# Load environment variables
Dotenv.load

require_relative 'app/models/user'
require_relative 'app/models/user_store'
require_relative 'app/services/auth_strategies/base_strategy'
require_relative 'app/services/auth_strategies/jwt_auth'
require_relative 'app/controllers/auth_controller'
require_relative 'app/controllers/products_controller'
require_relative 'app/middlewares/auth_middleware'
require_relative 'app/services/auth_service'
require_relative 'app/services/static_file_server'

class App
  def self.new
    Rack::Builder.new do
      use Rack::Deflater

      map '/api/v1/log_in' do
        run AuthController.new
      end

      map '/api/v1/products' do
        use AuthMiddleware, strategy: AuthStrategies::JWTAuth.new
        run ProductsController.new
      end

      map '/openapi.yaml' do
        run StaticFileServer.new('openapi.yaml', 'application/x-yaml', 'no-cache, no-store, must-revalidate')
      end

      map '/AUTHORS' do
        run StaticFileServer.new('AUTHORS', 'text/plain', 'max-age=86400')
      end

      map '/' do
        run lambda { |_env|
          [200, { 'Content-Type' => 'application/json' }, ['{"message": "Fudo API", "version": "1.0.0"}']]
        }
      end
    end
  end
end
