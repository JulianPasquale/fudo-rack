# frozen_string_literal: true

require_relative 'application_controller'
require_relative '../services/product_store'

class ProductsController < ApplicationController
  def initialize(request)
    super(request)
    @product_store = ProductStore.instance
  end

  def create
    # Check if JSON parsing failed for content-type application/json
    if request.content_type == 'application/json' && parse_json_body(request).nil?
      return json_bad_request('Invalid JSON')
    end

    name = params['name']
    return json_bad_request('Name is required') unless name && !name.to_s.strip.empty?

    user = current_user(request.env)

    product = @product_store.create_product_async(name)

    json_accepted({
      id: product.id,
      status: 'pending',
      message: 'Product creation started. It will be available in 5 seconds.',
      created_by: user.username
    })
  end

  def index
    products = @product_store.all_products.map(&:to_h)
    json_ok({ products: products })
  end

  def status
    id = params['id']
    return json_bad_request('ID parameter is required') unless id && !id.to_s.strip.empty?

    result = @product_store.product_status(id)

    if result
      if result[:status] == 'completed'
        json_ok({
          id: id,
          status: result[:status],
          product: result[:product].to_h
        })
      else
        json_ok({
          id: id,
          status: result[:status]
        })
      end
    else
      json_not_found('Product not found')
    end
  end
end
