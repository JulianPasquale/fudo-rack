# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
  end
end
