# frozen_string_literal: true

require_relative '../models/user_store'
require_relative 'auth_strategies/jwt_auth'

class AuthService
  def initialize(strategy: AuthStrategies::JWTAuth.new)
    @strategy = strategy
  end

  def generate_token(username, password)
    user = UserStore.instance.find_by_username(username)
    return unless user&.authenticate(password)

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

    UserStore.instance.find_by_username(payload['username'])
  end

  private

  attr_reader :strategy
end
