# frozen_string_literal: true

require 'json'
require_relative '../models/product_store'

class ProductsController
  def call(env)
    request = Rack::Request.new(env)

    case request.request_method
    when 'POST'
      create_product(request)
    when 'GET'
      get_products
    else
      method_not_allowed
    end
  end

  private

  def create_product(request)
    body = JSON.parse(request.body.read) rescue {}
    name = body['name']

    return bad_request('Missing product name') if name.nil? || name.empty?

    product = Product.new(name: name)
    id = ProductStore.instance.add_product_async(product)
    response = {
      id: id,
      message: 'Product creation started. It will be available in 5 seconds.',
      status: 'pending'
    }
    json_response(202, response)
  end

  def get_products
    products = ProductStore.instance.get_products.map(&:to_h)
    json_response(200, { products: products })
  end

  def json_response(status, data)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(data)]]
  end

  def method_not_allowed
    [405, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: 'Method not allowed' })]]
  end

  def bad_request(message)
    [400, { 'Content-Type' => 'application/json' }, [JSON.generate({ error: message })]]
  end
end
