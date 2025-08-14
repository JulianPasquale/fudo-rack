# frozen_string_literal: true

require 'concurrent'
require 'singleton'
require_relative 'product'

class ProductStore
  include Singleton

  def initialize
    @products = Concurrent::Hash.new
  end

  def add_product_async(product)
    Concurrent::ScheduledTask.execute(5) do
      @products[product.id] = product
    end

    product.id
  end

  def get_products
    @products.values
  end

  def get_product(id)
    @products[id]
  end

  def product_exists?(id)
    @products.key?(id)
  end

  def products_count
    @products.size
  end
end
