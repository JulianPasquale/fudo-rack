# frozen_string_literal: true

require 'concurrent'
require 'singleton'

module Products
  class CreateService
    def create(name)
      product = Product.new(name: name)

      Concurrent::ScheduledTask.execute(5) do
        # Use mutex to ensure thread-safe writes to store
        mutex.synchronize do
          ProductStore.instance.add_product(product)
        end
      end

      product.id
    end

    private

    def mutex
      @mutex ||= Mutex.new
    end
  end
end
