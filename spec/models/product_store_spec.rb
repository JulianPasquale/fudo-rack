# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductStore do
  let(:store) { ProductStore.instance }
  let(:product) { Product.new(name: 'Test Product') }

  describe 'singleton behavior' do
    it 'returns the same instance' do
      store1 = ProductStore.instance
      store2 = ProductStore.instance
      expect(store1).to be(store2)
    end

    it 'does not allow direct instantiation' do
      expect { ProductStore.new }.to raise_error(NoMethodError)
    end
  end

  describe '#add_product_async' do
    it 'returns the product id immediately' do
      id = store.add_product_async(product)
      expect(id).to eq(product.id)
    end

    it 'does not add product immediately' do
      store.add_product_async(product)
      expect(store.get_products).to be_empty
    end

    it 'adds product after delay' do
      store.add_product_async(product)
      
      # Wait a bit more than 5 seconds for the async task
      sleep(6)
      
      expect(store.get_products).to include(product)
    end
  end

  describe '#get_products' do
    context 'when no products exist' do
      it 'returns an empty array' do
        expect(store.get_products).to eq([])
      end
    end

    context 'when products exist' do
      before do
        # Add product synchronously for testing
        store.instance_variable_get(:@products)[product.id] = product
      end

      it 'returns all products' do
        expect(store.get_products).to include(product)
      end
    end
  end

  describe '#get_product' do
    context 'when product exists' do
      before do
        store.instance_variable_get(:@products)[product.id] = product
      end

      it 'returns the product' do
        expect(store.get_product(product.id)).to eq(product)
      end
    end

    context 'when product does not exist' do
      it 'returns nil' do
        expect(store.get_product('non-existent-id')).to be_nil
      end
    end
  end

  describe '#product_exists?' do
    context 'when product exists' do
      before do
        store.instance_variable_get(:@products)[product.id] = product
      end

      it 'returns true' do
        expect(store.product_exists?(product.id)).to be true
      end
    end

    context 'when product does not exist' do
      it 'returns false' do
        expect(store.product_exists?('non-existent-id')).to be false
      end
    end
  end

  describe '#products_count' do
    context 'when no products exist' do
      it 'returns 0' do
        expect(store.products_count).to eq(0)
      end
    end

    context 'when products exist' do
      before do
        store.instance_variable_get(:@products)[product.id] = product
      end

      it 'returns the correct count' do
        expect(store.products_count).to eq(1)
      end
    end
  end

  describe 'thread safety' do
    it 'uses Concurrent::Hash for thread-safe operations' do
      products_hash = store.instance_variable_get(:@products)
      expect(products_hash).to be_a(Concurrent::Hash)
    end
  end
end