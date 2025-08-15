# frozen_string_literal: true

require 'json'
require_relative '../services/auth_service'

class AuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    auth_header = request.get_header('HTTP_AUTHORIZATION')

    return unauthorized_response if auth_header.nil? || !auth_header&.start_with?('Bearer ')

    token = auth_header[7..]

    return unauthorized_response unless AuthService.token_valid?(token)

    env['current_user'] = AuthService.extract_username(token)
    @app.call(env)
  end

  private

  def unauthorized_response
    [401, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Unauthorized' })]]
  end
end
