# frozen_string_literal: true

class App
  def self.new
    Rack::Builder.new do
      use Rack::Deflater

      map '/api/v1/log_in' do
        use JSONValidator, require_json: true
        run AuthController.new
      end

      map '/api/v1/products' do
        use JSONValidator, require_json: true
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
