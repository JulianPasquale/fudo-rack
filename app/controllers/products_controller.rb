# frozen_string_literal: true

require 'json'
require_relative '../models/product_store'
require_relative '../services/products/create_service'

class ProductsController
  def call(env)
    request = Rack::Request.new(env)

    case request.request_method
    when 'POST'
      create(request)
    when 'GET'
      index
    else
      method_not_allowed
    end
  end

  private

  def create(request)
    body = begin
      JSON.parse(request.body.read)
    rescue StandardError
      {}
    end
    name = body['name']

    return bad_request('Missing product name') if name.nil? || name.empty?

    id = Products::CreateService.new.create(name)
    response = {
      id: id,
      message: 'Product creation started. It will be available in 5 seconds.',
      status: 'pending'
    }
    json_response(202, response)
  end

  def index
    products = ProductStore.instance.products.map(&:to_h)
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
