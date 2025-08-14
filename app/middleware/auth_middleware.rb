# frozen_string_literal: true

require_relative '../services/auth_service'

class AuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    # Skip authentication for public endpoints or non-API routes
    return @app.call(env) if public_endpoint?(request.path, request.request_method) || !api_route?(request.path)

    # Check for authentication
    auth_header = env['HTTP_AUTHORIZATION']

    unless auth_header&.start_with?('Bearer ')
      return unauthorized_response
    end

    token = auth_header.split(' ').last
    user = AuthService.valid_token?(token)

    unless user
      return unauthorized_response
    end

    # Add user instance to env for controllers to use
    env['current_user'] = user

    @app.call(env)
  end

  private

  def public_endpoint?(path, method)
    public_routes = [
      ['POST', '/api/auth'],
      ['GET', '/openapi.yaml'],
      ['GET', '/AUTHORS']
    ]

    public_routes.include?([method, path])
  end

  def api_route?(path)
    path.start_with?('/api/')
  end

  def unauthorized_response
    [401, { 'Content-Type' => 'application/json' }, ['{"error":"Unauthorized"}']]
  end
end
