# frozen_string_literal: true

require 'json'
require_relative '../services/auth_service'
require_relative '../services/auth_strategies/jwt_auth'

class AuthMiddleware
  def initialize(app, strategy: AuthStrategies::JWTAuth.new)
    @app = app
    @auth_service = AuthService.new(strategy: strategy)
  end

  def call(env)
    request = Rack::Request.new(env)
    auth_header = request.get_header('HTTP_AUTHORIZATION')

    return unauthorized_response if auth_header.nil? || !auth_header&.start_with?('Bearer ')

    token = auth_header[7..]

    return unauthorized_response unless (user = @auth_service.user_for_token(token))

    env['current_user'] = user
    @app.call(env)
  end

  private

  def unauthorized_response
    [401, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Unauthorized' })]]
  end
end
