# frozen_string_literal: true

require 'json'
require_relative '../services/auth_service'
require_relative '../services/auth_strategies/jwt_auth'

class AuthController
  def initialize(strategy: AuthStrategies::JWTAuth.new)
    @auth_service = AuthService.new(strategy: strategy)
  end

  def call(env)
    request = Rack::Request.new(env)

    return method_not_allowed unless request.post?

    params = request.env['rack.parsed_params'] || {}
    username = params['username']
    password = params['password']

    return bad_request('Missing username or password') if username.nil? || password.nil?

    auth_result = @auth_service.generate_token(username, password)

    return json_response(401, { error: 'Invalid credentials' }) unless auth_result

    json_response(200, { token: auth_result[:token], expires_in: auth_result[:expires_in] })
  end

  private

  def json_response(status, data)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(data)]]
  end

  def method_not_allowed
    [405, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Method not allowed' })]]
  end

  def bad_request(message)
    [400, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: message })]]
  end
end
