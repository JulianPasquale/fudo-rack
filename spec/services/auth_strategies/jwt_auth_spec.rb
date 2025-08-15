# frozen_string_literal: true

RSpec.describe AuthStrategies::JWTAuth do
  let(:secret) { 'test_secret_key' }
  let(:user) { User.new(username: 'testuser', password: 'password') }

  subject { described_class.new(secret: secret) }

  describe '#generate_token' do
    it 'generates a JWT token' do
      token = subject.generate_token(user)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts

      payload = JWT.decode(token, secret, true, { algorithm: described_class::ALGORITHM }).first
      expect(payload['username']).to eq(user.username)
      expect(payload['user_id']).to eq(user.id)
      expect(payload['iat']).to be_a(Integer)
      expect(payload['exp']).to be_a(Integer)
      expect(payload['exp']).to eq(payload['iat'] + described_class::EXPIRATION_TIME)
    end

    it 'generates different tokens for different users' do
      user2 = User.new(username: 'user2', password: 'password')
      token1 = subject.generate_token(user)
      token2 = subject.generate_token(user2)
      expect(token1).not_to eq(token2)
    end
  end

  describe '#decode_token' do
    let(:valid_token) { subject.generate_token(user) }

    context 'with valid token' do
      it 'returns the payload hash' do
        payload = subject.decode_token(valid_token)
        expect(payload).to be_a(Hash)
        expect(payload['username']).to eq(user.username)
      end
    end

    context 'with invalid token' do
      it 'returns nil for malformed token' do
        expect(subject.decode_token('invalid.token')).to be_nil
      end

      it 'returns nil for expired token' do
        expired_payload = {
          username: user.username,
          user_id: user.id,
          iat: Time.now.to_i - 7200, # 2 hours ago
          exp: Time.now.to_i - 3600  # 1 hour ago (expired)
        }
        expired_token = JWT.encode(expired_payload, secret, described_class::ALGORITHM)
        expect(subject.decode_token(expired_token)).to be_nil
      end

      it 'returns nil for nil token' do
        expect(subject.decode_token(nil)).to be_nil
      end
    end

    context 'when signature is wrong' do
      it 'returns nil' do
        fake_token = described_class.new(secret: 'wrong_secret').generate_token(user)
        expect(subject.decode_token(fake_token)).to be_nil
      end
    end
  end

  describe 'constants' do
    it 'has correct algorithm' do
      expect(described_class::ALGORITHM).to eq('HS256')
    end

    it 'has correct expiration time' do
      expect(described_class::EXPIRATION_TIME).to eq(3600)
    end
  end
end
