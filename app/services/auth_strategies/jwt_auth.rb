# frozen_string_literal: true

require 'jwt'

module AuthStrategies
  class JWTAuth < BaseStrategy
    ALGORITHM = 'HS256'
    EXPIRATION_TIME = 3600

    def initialize(secret: ENV.fetch('JWT_SECRET', 'your_secret_key_here'))
      @secret = secret
    end

    def generate_token(user)
      payload = {
        username: user.username,
        user_id: user.id,
        iat: Time.now.to_i,
        exp: Time.now.to_i + EXPIRATION_TIME
      }

      JWT.encode(payload, secret, ALGORITHM)
    end

    def decode_token(token)
      decoded = JWT.decode(token, secret, true, { algorithm: ALGORITHM })
      decoded.first # Return the payload
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidIatError
      nil
    end

    def expiration
      EXPIRATION_TIME
    end

    private

    attr_reader :secret
  end
end
