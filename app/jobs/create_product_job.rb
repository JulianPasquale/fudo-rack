# frozen_string_literal: true

class CreateProductJob
  include Sidekiq::Job

  sidekiq_options retry: 3

  def perform(args)
    product_name = args['product_name']
    Product.create!(name: product_name)
  end
end
