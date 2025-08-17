# frozen_string_literal: true

class User < ApplicationRecord
  before_create :hash_password_field

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  attr_accessor :password

  def authenticated?(password)
    BCrypt::Password.new(password_hash) == password
  end

  def to_h
    {
      id: id,
      username: username,
      created_at: created_at
    }
  end

  def to_json(*)
    to_h.to_json(*)
  end

  private

  def hash_password_field
    self.password_hash = BCrypt::Password.create(password) if password
  end
end
