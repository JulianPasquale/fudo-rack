# frozen_string_literal: true

require 'json'

class AuthMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    auth_header = request.get_header('HTTP_AUTHORIZATION')

    if auth_header&.start_with?('Bearer ')
      token = auth_header[7..]
      if valid_token?(token)
        env['current_user'] = extract_user_from_token(token)
        @app.call(env)
      else
        unauthorized_response
      end
    else
      unauthorized_response
    end
  end

  private

  def valid_token?(token)
    token&.start_with?('token_') && token.split('_').length >= 3
  end

  def extract_user_from_token(token)
    parts = token.split('_')
    parts[1] if parts.length >= 3
  end

  def unauthorized_response
    [401, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Unauthorized' })]]
  end
end
