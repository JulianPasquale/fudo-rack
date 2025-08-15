# frozen_string_literal: true

require 'jwt'
require_relative '../models/user_store'

class AuthService
  JWT_SECRET = ENV.fetch('JWT_SECRET', 'your_secret_key_here').freeze
  ALGORITHM = 'HS256'
  EXPIRATION_TIME = 3600

  class << self
    def generate_token(username)
      payload = {
        username: username,
        iat: Time.now.to_i,
        exp: Time.now.to_i + EXPIRATION_TIME
      }

      JWT.encode(payload, JWT_SECRET, ALGORITHM)
    end

    def decode_token(token)
      decoded = JWT.decode(token, JWT_SECRET, true, { algorithm: ALGORITHM })
      decoded.first # Return the payload
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidIatError
      nil
    end

    def token_valid?(token)
      !decode_token(token).nil?
    end

    def extract_username(token)
      payload = decode_token(token)
      payload&.dig('username')
    end

    def authenticate(username, password)
      UserStore.instance.authenticate(username, password)
    end

    def find_user_by_username(username)
      UserStore.instance.find_by_username(username)
    end
  end
end
