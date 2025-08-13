# frozen_string_literal: true

class User
  attr_reader :id, :username, :created_at

  def initialize(username)
    @id = SecureRandom.uuid
    @username = username
    @created_at = Time.now
  end

  def to_h
    {
      id: @id,
      username: @username,
      created_at: @created_at.iso8601
    }
  end

  # Class methods for user management
  class << self
    def find_by_credentials(username, password)
      # For now, we only have one hardcoded user
      return new('admin') if username == 'admin' && password == 'secret'
      nil
    end

    def find_by_username(username)
      return new('admin') if username == 'admin'
      nil
    end
  end
end