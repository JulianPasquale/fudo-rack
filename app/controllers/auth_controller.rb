# frozen_string_literal: true

require 'json'
require_relative '../services/auth_service'

class AuthController
  def call(env)
    request = Rack::Request.new(env)

    return method_not_allowed unless request.post?

    body = begin
      JSON.parse(request.body.read)
    rescue StandardError
      {}
    end
    username = body['username']
    password = body['password']

    return bad_request('Missing username or password') if username.nil? || password.nil?

    if AuthService.authenticate(username, password)
      token = AuthService.generate_token(username)
      response = { token: token, expires_in: AuthService::EXPIRATION_TIME }
      json_response(200, response)
    else
      json_response(401, { error: 'Invalid credentials' })
    end
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
