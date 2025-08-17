# frozen_string_literal: true

RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe '#to_h' do
    let(:product) { create(:product, name: 'Test Product') }
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
    let(:product) { create(:product, name: 'Test Product') }

    it 'returns a JSON string' do
      json_string = product.to_json
      expect(json_string).to be_a(String)

      parsed = JSON.parse(json_string)
      expect(parsed['name']).to eq('Test Product')
      expect(parsed['id']).to eq(product.id)
    end
  end
end
