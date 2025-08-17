# frozen_string_literal: true

RSpec.describe CreateProductJob do
  describe '#perform' do
    context 'with valid product parameters' do
      let(:product_params) { { 'name' => 'Test Product' } }

      it 'creates a product with the given name' do
        expect {
          CreateProductJob.new.perform(product_params)
        }.to change(Product, :count).by(1)

        product = Product.last
        expect(product.name).to eq('Test Product')
      end
    end

    context 'with invalid product parameters' do
      let(:product_params) { { 'name' => '' } }

      it 'raises an error for invalid product data' do
        expect {
          CreateProductJob.new.perform(product_params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create a product' do
        expect {
          begin
            CreateProductJob.new.perform(product_params)
          rescue ActiveRecord::RecordInvalid
            # Swallow the expected error
          end
        }.not_to change(Product, :count)
      end
    end

    context 'with missing name parameter' do
      let(:product_params) { {} }

      it 'raises an error for missing name' do
        expect {
          CreateProductJob.new.perform(product_params)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'Sidekiq configuration' do
    it 'includes Sidekiq::Job' do
      expect(CreateProductJob.ancestors).to include(Sidekiq::Job)
    end

    it 'has retry configured' do
      expect(CreateProductJob.get_sidekiq_options['retry']).to eq(3)
    end
  end
end