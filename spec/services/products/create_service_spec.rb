# frozen_string_literal: true

RSpec.describe Products::CreateService do
  subject { described_class.new }

  describe '#create' do
    let(:product_name) { 'Test Product' }

    it 'returns product id immediately' do
      id = subject.create(product_name)
      expect(id).to be_a(String)
      expect(id).not_to be_empty
    end

    it 'does not add product to store immediately' do
      initial_count = ProductStore.instance.products_count
      subject.create(product_name)
      expect(ProductStore.instance.products_count).to eq(initial_count)
    end

    context 'with multiple async operations in parallel' do
      let(:scheduled_task) { instance_double(Concurrent::ScheduledTask) }

      # This is to "stub" the async task. Another workaround would to add a sleep(6) in the test,
      # but that's super slow, so we can just test the class is being called with the expected arguments
      # and make it run synchronously.
      before do
        allow(Concurrent::ScheduledTask).to receive(:execute).with(5).and_yield.and_return(scheduled_task)
      end

      it 'schedules product to be added to store with delay' do
        expect(ProductStore.instance).to receive(:add_product) do |product|
          expect(product.name).to eq(product_name)
        end

        subject.create(product_name)
      end

      it 'handles concurrent requests safely' do
        # Create multiple products concurrently
        threads = []
        product_ids = []
        products_names = []

        5.times do |i|
          threads << Thread.new do
            product_name = "Product #{i}"
            id = subject.create(product_name)
            product_ids << id
            products_names << product_name
          end
        end

        threads.each(&:join)

        # All products should have unique IDs
        expect(product_ids.uniq.length).to eq(5)
        stored_names = ProductStore.instance.products.map(&:name)
        expect(stored_names).to match(products_names)
      end

      it 'uses mutex to synchronize store writes' do
        mutex = instance_double(Mutex, synchronize: true)
        allow(subject).to receive(:mutex).and_return(mutex)

        subject.create(product_name)
        expect(mutex).to have_received(:synchronize)
      end
    end
  end
end
