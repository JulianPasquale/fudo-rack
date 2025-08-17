# frozen_string_literal: true

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

  describe '#add_product' do
    it 'adds product immediately' do
      store.add_product(product)
      expect(store.products).to include(product)
    end

    it 'stores product with correct id' do
      store.add_product(product)
      expect(store.product(product.id)).to eq(product)
    end
  end

  describe '#products' do
    context 'when no products exist' do
      it 'returns an empty array' do
        expect(store.products).to eq([])
      end
    end

    context 'when products exist' do
      before do
        # Add product synchronously for testing
        store.instance_variable_get(:@products)[product.id] = product
      end

      it 'returns all products' do
        expect(store.products).to include(product)
      end
    end
  end

  describe '#product' do
    context 'when product exists' do
      before do
        store.instance_variable_get(:@products)[product.id] = product
      end

      it 'returns the product' do
        expect(store.product(product.id)).to eq(product)
      end
    end

    context 'when product does not exist' do
      it 'returns nil' do
        expect(store.product('non-existent-id')).to be_nil
      end
    end
  end

  describe '#exists?' do
    context 'when product exists' do
      before do
        store.instance_variable_get(:@products)[product.id] = product
      end

      it 'returns true' do
        expect(store.exists?(product.id)).to be true
      end
    end

    context 'when product does not exist' do
      it 'returns false' do
        expect(store.exists?('non-existent-id')).to be false
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
