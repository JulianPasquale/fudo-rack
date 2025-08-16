# frozen_string_literal: true

RSpec.describe Product do
  describe '#initialize' do
    context 'with name only' do
      let(:product) { Product.new(name: 'Test Product') }

      it 'creates a product with a name' do
        expect(product.name).to eq('Test Product')
      end

      it 'generates a UUID for id' do
        expect(product.id).to be_a(String)
        expect(product.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
      end

      it 'sets created_at to current time' do
        expect(product.created_at).to be_within(1).of(Time.now)
      end
    end

    context 'with custom id' do
      let(:custom_id) { 'custom-id-123' }
      let(:product) { Product.new(name: 'Test Product', id: custom_id) }

      it 'uses the provided id' do
        expect(product.id).to eq(custom_id)
      end
    end
  end

  describe '#to_h' do
    let(:product) { Product.new(name: 'Test Product') }
    let(:hash) { product.to_h }

    it 'returns a hash with all attributes' do
      expect(hash).to include(
        id: product.id,
        name: 'Test Product',
        created_at: product.created_at
      )
    end

    it 'returns a hash with symbol keys' do
      expect(hash.keys).to all(be_a(Symbol))
    end
  end

  describe '#to_json' do
    let(:product) { Product.new(name: 'Test Product') }

    it 'returns a JSON string' do
      json_string = product.to_json
      expect(json_string).to be_a(String)

      parsed = JSON.parse(json_string)
      expect(parsed['name']).to eq('Test Product')
      expect(parsed['id']).to eq(product.id)
    end
  end

  describe 'attribute access' do
    let(:product) { Product.new(name: 'Test Product') }

    it 'provides read-only access to id' do
      expect(product).to respond_to(:id)
      expect(product).not_to respond_to(:id=)
    end

    it 'provides read-only access to name' do
      expect(product).to respond_to(:name)
      expect(product).not_to respond_to(:name=)
    end

    it 'provides read-only access to created_at' do
      expect(product).to respond_to(:created_at)
      expect(product).not_to respond_to(:created_at=)
    end
  end
end
