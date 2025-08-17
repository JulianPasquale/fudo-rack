# frozen_string_literal: true

class Product < ActiveRecord::Base
  validates :name, presence: true

  def to_h
    {
      id: id,
      name: name,
      created_at: created_at
    }
  end

  def to_json(*)
    to_h.to_json(*)
  end
end
