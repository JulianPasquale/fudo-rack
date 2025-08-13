# frozen_string_literal: true

require 'securerandom'

class Product
  attr_reader :id, :name, :created_at

  def initialize(name)
    @id = SecureRandom.uuid
    @name = name
    @created_at = Time.now
  end

  def to_h
    {
      id: @id,
      name: @name,
      created_at: @created_at.iso8601
    }
  end
end