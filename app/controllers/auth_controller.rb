# frozen_string_literal: true

require 'json'

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

    if authenticate(username, password)
      token = generate_token(username)
      response = { token: token, expires_in: 3600 }
      json_response(200, response)
    else
      json_response(401, { error: 'Invalid credentials' })
    end
  end

  private

  def authenticate(username, password)
    username == 'admin' && password == 'password'
  end

  def generate_token(username)
    "token_#{username}_#{Time.now.to_i}"
  end

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
