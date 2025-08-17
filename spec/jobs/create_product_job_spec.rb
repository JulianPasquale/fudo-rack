# frozen_string_literal: true

RSpec.describe CreateProductJob do
  describe '#perform' do
    context 'with valid product name' do
      it 'creates a product with the given name' do
        expect {
          CreateProductJob.new.perform('product_name' => 'Test Product')
        }.to change(Product, :count).by(1)

        product = Product.last
        expect(product.name).to eq('Test Product')
      end
    end

    context 'with invalid product name' do
      it 'raises an error for empty product name' do
        expect {
          CreateProductJob.new.perform('product_name' => '')
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create a product with empty name' do
        expect {
          begin
            CreateProductJob.new.perform('product_name' => '')
          rescue ActiveRecord::RecordInvalid
            # Swallow the expected error
          end
        }.not_to change(Product, :count)
      end

      it 'raises an error for nil product name' do
        expect {
          CreateProductJob.new.perform('product_name' => nil)
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