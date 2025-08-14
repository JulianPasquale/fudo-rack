# frozen_string_literal: true

require_relative 'application_controller'
require_relative '../services/product_store'

class ProductsController < ApplicationController
  def initialize
    @product_store = ProductStore.new
  end

  def create(request)
    return json_bad_request('Invalid JSON') unless params

    name = params['name']
    return json_bad_request('Name is required') unless name

    user = current_user(request.env)

    product = @product_store.create_product_async(name)

    json_accepted({
      id: product.id,
      status: 'pending',
      message: 'Product creation started. It will be available in 5 seconds.',
      created_by: user.username
    })
  end

  def index(request)
    products = @product_store.all_products.map(&:to_h)
    json_ok({ products: products })
  end

  def status(request)
    id = request.params['id']
    return json_bad_request('ID parameter is required') unless id

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
