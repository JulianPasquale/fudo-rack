# frozen_string_literal: true

RSpec.describe AuthService do
  let(:strategy) { AuthStrategies::JWTAuth.new(secret: 'test_secret') }
  subject { described_class.new(strategy: strategy) }

  let!(:admin_user) { create(:user, username: 'admin', password: 'password') }

  describe '#generate_token' do
    context 'with valid credentials' do
      it 'returns hash with user, token and expires_in' do
        result = subject.generate_token('admin', 'password')

        expect(result).to be_a(Hash)
        expect(result[:user]).to be_a(User)
        expect(result[:user].username).to eq('admin')
        expect(result[:expires_in]).to eq(strategy.expiration)

        expect(result[:token]).to be_a(String)
        # Make sure it is a JWT. It has 3 parts separated by a '.'
        expect(result[:token].split('.').length).to eq(3)
      end
    end

    context 'with invalid credentials' do
      it 'returns nil for wrong username' do
        result = subject.generate_token('wrong', 'password')
        expect(result).to be_nil
      end

      it 'returns nil for wrong password' do
        result = subject.generate_token('admin', 'wrong')
        expect(result).to be_nil
      end

      it 'returns nil for nil credentials' do
        result = subject.generate_token(nil, nil)
        expect(result).to be_nil
      end
    end
  end

  describe '#user_for_token' do
    it 'returns the user instance' do
      expect(subject.user_for_token(strategy.generate_token(admin_user))).to eq(admin_user)
    end

    context 'when token is invalid' do
      it 'returns nil for invalid token' do
        expect(subject.user_for_token('invalid.token')).to be_nil
      end
    end
  end
end
