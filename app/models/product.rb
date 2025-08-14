# frozen_string_literal: true

require 'securerandom'

class Product
  attr_reader :id, :name, :created_at

  def initialize(name, id: nil)
    @id = id || SecureRandom.uuid
    @name = name
    @created_at = Time.now
  end

  def to_h
    {
      id: @id,
      name: @name,
      created_at: @created_at
    }
  end

  def to_json(*args)
    to_h.to_json(*args)
  end
end
