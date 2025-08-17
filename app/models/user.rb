# frozen_string_literal: true

require 'securerandom'
require 'bcrypt'

class User
  attr_reader :id, :username, :created_at

  def initialize(username:, password:, id: nil)
    @id = id || SecureRandom.uuid
    @username = username
    @password_hash = hash_password(password)
    @created_at = Time.now
  end

  def authenticated?(password)
    BCrypt::Password.new(@password_hash) == password
  end

  def to_h
    {
      id: @id,
      username: @username,
      created_at: @created_at
    }
  end

  def to_json(*)
    to_h.to_json(*)
  end

  private

  def hash_password(password)
    BCrypt::Password.create(password)
  end
end
