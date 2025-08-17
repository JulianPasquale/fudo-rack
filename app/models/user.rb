# frozen_string_literal: true

require 'securerandom'
require 'digest'

class User
  attr_reader :id, :username, :created_at

  def initialize(username:, password:, id: nil)
    @id = id || SecureRandom.uuid
    @username = username
    @password_hash = hash_password(password)
    @created_at = Time.now
  end

  def authenticated?(password)
    hash_password(password) == @password_hash
  end

  # Backward compatibility for tests
  alias authenticate authenticated?

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
    # Simple password hashing (in production, use bcrypt)
    Digest::SHA256.hexdigest("#{password}#{salt}")
  end

  def salt
    # Simple salt (in production, generate random salt per user)
    'fudo_api_salt_2024'
  end
end
