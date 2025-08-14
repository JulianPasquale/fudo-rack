# frozen_string_literal: true

require 'rack'
require 'rack/deflater'
require_relative 'app/controllers/auth_controller'
require_relative 'app/controllers/products_controller'
require_relative 'app/middlewares/auth_middleware'
require_relative 'app/services/static_file_server'

class App
  def self.new
    Rack::Builder.new do
      use Rack::Deflater

      map '/auth' do
        run AuthController.new
      end

      map '/products' do
        use AuthMiddleware
        run ProductsController.new
      end

      map '/openapi.yaml' do
        run StaticFileServer.new('openapi.yaml', 'application/x-yaml', 'no-cache, no-store, must-revalidate')
      end

      map '/AUTHORS' do
        run StaticFileServer.new('AUTHORS', 'text/plain', 'max-age=86400')
      end
    end
  end
end
