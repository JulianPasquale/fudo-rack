# frozen_string_literal: true

require 'concurrent'
require 'singleton'
require 'dotenv'
require_relative 'user'

# Load environment variables
Dotenv.load

class UserStore
  include Singleton

  def initialize
    @users = Concurrent::Hash.new
    @users_by_username = Concurrent::Hash.new
    initialize_default_user
  end

  def add_user(user)
    @users[user.id] = user
    @users_by_username[user.username] = user
    user
  end

  def find_by_username(username)
    @users_by_username[username]
  end

  def find_by_id(id)
    @users[id]
  end

  def user_exists?(username)
    @users_by_username.key?(username)
  end

  def users
    @users.values
  end

  def users_count
    @users.size
  end

  def authenticate(username, password)
    user = find_by_username(username)
    user&.authenticate(password) || false
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
