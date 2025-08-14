# frozen_string_literal: true

require 'concurrent'
require 'singleton'
require_relative 'product'

class ProductStore
  include Singleton

  def initialize(products: Concurrent::Hash.new)
    @products = products
  end

  def add_product_async(product)
    Concurrent::ScheduledTask.execute(5) do
      @products[product.id] = product
    end

    product.id
  end

  def products
    @products.values
  end

  def product(id)
    @products[id]
  end

  def exists?(id)
    @products.key?(id)
  end

  def products_count
    @products.size
  end
end
