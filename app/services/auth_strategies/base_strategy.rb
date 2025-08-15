# frozen_string_literal: true

# Base class for authentication strategies
# Defines the interface that all authentication strategies must implement
module AuthStrategies
  class BaseStrategy
    # Generate a token for the given user
    # @param user [User] The authenticated user
    # @return [String] The generated token
    def generate_token(user)
      raise NotImplementedError, "#{self.class} must implement #generate_token"
    end

    # Decode and validate a token
    # @param token [String] The token to decode
    # @return [Hash, nil] The decoded payload or nil if invalid
    def decode_token(token)
      raise NotImplementedError, "#{self.class} must implement #decode_token"
    end

    # Return the expiration time of the generated tokens
    # @return [Ingeter] Token validity in seconds
    def expiration
      raise NotImplementedError, "#{self.class} must implement #expiration"
    end
  end
end
