# frozen_string_literal: true

require 'jwt'
require_relative '../models/user'

class AuthService
  JWT_SECRET = 'fudo_secret_key_change_in_production'
  JWT_ALGORITHM = 'HS256'

  class << self
    def authenticate(username, password)
      user = User.find_by_credentials(username, password)
      return nil unless user

      payload = {
        user_id: user.id,
        username: user.username,
        exp: Time.now.to_i + (24 * 60 * 60) # 24 hours
      }

      {
        token: JWT.encode(payload, JWT_SECRET, JWT_ALGORITHM),
        user: user
      }
    end

    def valid_token?(token)
      decoded = JWT.decode(token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM })
      payload = decoded.first
      
      # Return the user if token is valid
      User.find_by_username(payload['username'])
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    def extract_user_from_token(token)
      decoded = JWT.decode(token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM })
      payload = decoded.first
      User.find_by_username(payload['username'])
    rescue JWT::DecodeError
      nil
    end
  end
end
