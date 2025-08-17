# frozen_string_literal: true

require 'singleton'

class UserStore
  include Singleton

  def initialize
    @users_by_username = Concurrent::Hash.new
    initialize_default_user
  end

  def add_user(user)
    @users_by_username[user.username] = user
    user
  end

  def find_by_username(username)
    @users_by_username[username]
  end

  def user_exists?(username)
    @users_by_username.key?(username)
  end

  def users
    @users_by_username.values
  end

  private

  def initialize_default_user
    username = ENV.fetch('USERNAME', 'admin')
    password = ENV.fetch('PASSWORD', 'password')

    default_user = User.new(
      username: username,
      password: password
    )

    add_user(default_user)
  end
end
