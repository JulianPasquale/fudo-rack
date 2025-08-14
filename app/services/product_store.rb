# frozen_string_literal: true

require 'singleton'
require_relative '../models/product'

class ProductStore
  include Singleton
  
  def initialize
    @products = {}
    @pending_products = {}
  end

  def create_product_async(name)
    product = Product.new(name)
    @pending_products[product.id] = product

    # Simulate async processing - product will be available after 5 seconds
    Thread.new do
      sleep(5)
      @products[product.id] = @pending_products.delete(product.id)
    end

    product
  end

  def find_product(id)
    @products[id]
  end

  def all_products
    @products.values
  end

  def product_status(id)
    if @products.key?(id)
      { status: 'completed', product: @products[id] }
    elsif @pending_products.key?(id)
      { status: 'pending' }
    else
      nil
    end
  end

  def reset!
    @products.clear
    @pending_products.clear
  end
end