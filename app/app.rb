# frozen_string_literal: true

class App
  def self.new
    Rack::Builder.new do
      use Rack::Deflater

      configure_api_routes(self)
      configure_static_routes(self)
      configure_fallback_route(self)
    end
  end

  def self.configure_api_routes(builder)
    builder.map '/api/v1/log_in' do
      use JSONValidator, require_json: true
      run AuthController.new
    end

    builder.map '/api/v1/products' do
      use JSONValidator, require_json: true
      use AuthMiddleware, strategy: AuthStrategies::JWTAuth.new
      run ProductsController.new
    end
  end

  def self.configure_static_routes(builder)
    builder.map '/openapi.yaml' do
      run StaticFileServer.new('openapi.yaml', 'application/x-yaml', 'no-cache, no-store, must-revalidate')
    end

    builder.map '/AUTHORS' do
      run StaticFileServer.new('AUTHORS', 'text/plain', 'max-age=86400')
    end
  end

  def self.configure_fallback_route(builder)
    builder.map '/' do
      run ->(_env) { ResponseHandler.error(:not_found, 'Not Found') }
    end
  end
end
