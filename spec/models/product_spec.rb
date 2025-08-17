# frozen_string_literal: true

RSpec.describe Product do
  describe 'validations' do
    it 'validates presence of name' do
      product = Product.new
      expect(product.valid?).to be false
      expect(product.errors[:name]).to include("can't be blank")
    end

    it 'is valid with a name' do
      product = Product.new(name: 'Test Product')
      expect(product.valid?).to be true
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      let(:product) { Product.create!(name: 'Test Product') }

      it 'creates a product with a name' do
        expect(product.name).to eq('Test Product')
      end

      it 'generates an auto-incrementing id' do
        expect(product.id).to be_a(Integer)
        expect(product.id).to be > 0
      end

      it 'sets created_at and updated_at' do
        expect(product.created_at).to be_within(1).of(Time.now)
        expect(product.updated_at).to be_within(1).of(Time.now)
      end
    end
  end

  describe '#to_h' do
    let(:product) { Product.create!(name: 'Test Product') }
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
    let(:product) { Product.create!(name: 'Test Product') }

    it 'returns a JSON string' do
      json_string = product.to_json
      expect(json_string).to be_a(String)

      parsed = JSON.parse(json_string)
      expect(parsed['name']).to eq('Test Product')
      expect(parsed['id']).to eq(product.id)
    end
  end

  describe 'attribute access' do
    let(:product) { Product.create!(name: 'Test Product') }

    it 'provides access to id' do
      expect(product).to respond_to(:id)
      expect(product).to respond_to(:id=)
    end

    it 'provides access to name' do
      expect(product).to respond_to(:name)
      expect(product).to respond_to(:name=)
    end

    it 'provides access to created_at' do
      expect(product).to respond_to(:created_at)
      expect(product).to respond_to(:created_at=)
    end
  end
end
