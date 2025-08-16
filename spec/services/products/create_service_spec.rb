# frozen_string_literal: true

RSpec.describe Products::CreateService do
  let(:service) { described_class.new }
  let(:product_name) { 'Test Product' }

  describe '#create' do
    it 'returns product id immediately' do
      id = service.create(product_name)
      expect(id).to be_a(String)
      expect(id).not_to be_empty
    end

    it 'does not add product to store immediately' do
      initial_count = ProductStore.instance.products_count
      service.create(product_name)
      expect(ProductStore.instance.products_count).to eq(initial_count)
    end

    it 'adds product to store after delay' do
      id = service.create(product_name)
      
      # Wait for async task to complete
      sleep(6)
      
      expect(ProductStore.instance.exists?(id)).to be true
      product = ProductStore.instance.product(id)
      expect(product.name).to eq(product_name)
    end

    it 'handles concurrent requests safely' do
      # Create multiple products concurrently
      threads = []
      product_ids = []

      5.times do |i|
        threads << Thread.new do
          id = service.create("Product #{i}")
          product_ids << id
        end
      end

      threads.each(&:join)

      # All products should have unique IDs
      expect(product_ids.uniq.length).to eq(5)
    end
  end

  describe 'thread safety' do
    it 'uses mutex for synchronization' do
      mutex = service.send(:mutex)
      expect(mutex).to be_a(Mutex)
    end

    it 'returns same mutex instance on multiple calls' do
      mutex1 = service.send(:mutex)
      mutex2 = service.send(:mutex)
      expect(mutex1).to be(mutex2)
    end
  end
end