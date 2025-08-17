# frozen_string_literal: true

class CreateProductJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  def perform(product_params)
    # Create product with the provided name
    Product.create!(name: product_params['name'])
  end
end