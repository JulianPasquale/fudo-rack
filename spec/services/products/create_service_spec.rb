# frozen_string_literal: true

RSpec.describe Products::CreateService do
  subject { described_class.new }

  describe '#create' do
    let(:product_name) { 'Test Product' }

    it 'returns pending status immediately' do
      result = subject.create(product_name)
      expect(result).to eq('pending')
    end

    it 'does not create product immediately' do
      expect { subject.create(product_name) }.not_to(change { Product.count })
    end

    it 'schedules a CreateProductJob with delay' do
      allow(CreateProductJob).to receive(:perform_in)
      
      subject.create(product_name)
      
      expect(CreateProductJob).to have_received(:perform_in).with(
        5.seconds, 
        { 'name' => product_name }
      )
    end

    context 'with multiple requests' do
      it 'schedules multiple jobs' do
        allow(CreateProductJob).to receive(:perform_in)
        
        3.times { |i| subject.create("Product #{i}") }
        
        expect(CreateProductJob).to have_received(:perform_in).exactly(3).times
      end
    end
  end
end
