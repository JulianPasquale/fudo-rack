# frozen_string_literal: true

class App
  def self.new
    Rack::Builder.new do
      use Rack::Deflater

      use Rack::Static,
          urls: ['/openapi.yaml', '/AUTHORS'],
          root: '.',
          header_rules: [
            # No cache for openapi
            [
              /openapi\.yaml/,
              { 'Content-Type' => 'application/x-yaml', 'Cache-Control' => 'no-cache, no-store, must-revalidate' }
            ],
            # 24 hour cache for AUTHORS
            [/AUTHORS/, { 'Content-Type' => 'text/plain', 'Cache-Control' => 'max-age=86400' }]
          ]

      map '/api/v1/log_in' do
        use JSONValidator, require_json: true
        run Api::V1::AuthController.new
      end

      map '/api/v1/products' do
        use JSONValidator, require_json: true
        use AuthMiddleware, strategy: AuthStrategies::JWTAuth.new
        run Api::V1::ProductsController.new
      end

      map '/' do
        run ->(_env) { ResponseHandler.error(:not_found, 'Not Found') }
      end
    end
  end
end
