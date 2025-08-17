# frozen_string_literal: true

class AuthService
  def initialize(strategy: AuthStrategies::JWTAuth.new)
    @strategy = strategy
  end

  def generate_token(username, password)
    user = User.find_by(username: username)
    return unless user&.authenticated?(password)

    token = strategy.generate_token(user)
    {
      user: user,
      token: token,
      expires_in: strategy.expiration
    }
  end

  def user_for_token(token)
    payload = strategy.decode_token(token)

    return unless payload

    User.find_by(username: payload['username'])
  end

  private

  attr_reader :strategy
end
