# frozen_string_literal: true

require 'json'

class AuthMiddleware
  def initialize(app, strategy: AuthStrategies::JWTAuth.new)
    @app = app
    @auth_service = AuthService.new(strategy: strategy)
  end

  def call(env)
    request = Rack::Request.new(env)
    auth_header = request.get_header('HTTP_AUTHORIZATION')

    return ResponseHandler.error(:unauthorized, 'Unauthorized') if auth_header.nil? || !auth_header&.start_with?('Bearer ')

    token = auth_header[7..]

    return ResponseHandler.error(:unauthorized, 'Unauthorized') unless (user = @auth_service.user_for_token(token))

    env['current_user'] = user
    @app.call(env)
  end

  private
end
