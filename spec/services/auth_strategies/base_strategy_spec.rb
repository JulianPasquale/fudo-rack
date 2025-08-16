# frozen_string_literal: true

RSpec.describe AuthStrategies::BaseStrategy do
  subject { described_class.new }
  let(:user) { User.new(username: 'testuser', password: 'password') }

  describe '#generate_token' do
    it 'raises NotImplementedError' do
      expect { subject.generate_token(user) }.to raise_error(NotImplementedError)
    end
  end

  describe '#decode_token' do
    it 'raises NotImplementedError' do
      expect { subject.decode_token('some_token') }.to raise_error(NotImplementedError)
    end
  end
end
