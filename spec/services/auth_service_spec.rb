# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuthService do
  describe '.authenticate' do
    it 'returns true for valid credentials using UserStore' do
      expect(AuthService.authenticate('admin', 'password')).to be true
    end

    it 'returns false for invalid username' do
      expect(AuthService.authenticate('wrong', 'password')).to be false
    end

    it 'returns false for invalid password' do
      expect(AuthService.authenticate('admin', 'wrong')).to be false
    end

    it 'returns false for nil credentials' do
      expect(AuthService.authenticate(nil, nil)).to be false
    end
  end

  describe '.find_user_by_username' do
    it 'returns user for existing username' do
      user = AuthService.find_user_by_username('admin')
      expect(user).not_to be_nil
      expect(user.username).to eq('admin')
    end

    it 'returns nil for non-existing username' do
      user = AuthService.find_user_by_username('nonexistent')
      expect(user).to be_nil
    end
  end

  describe '.generate_token' do
    let(:username) { 'admin' }
    let(:token) { AuthService.generate_token(username) }

    it 'generates a JWT token' do
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts separated by dots
    end

    it 'includes username in the payload' do
      payload = AuthService.decode_token(token)
      expect(payload['username']).to eq(username)
    end

    it 'includes iat (issued at) timestamp' do
      payload = AuthService.decode_token(token)
      expect(payload['iat']).to be_a(Integer)
      expect(payload['iat']).to be_within(5).of(Time.now.to_i)
    end

    it 'includes exp (expiration) timestamp' do
      payload = AuthService.decode_token(token)
      expect(payload['exp']).to be_a(Integer)
      expect(payload['exp']).to eq(payload['iat'] + AuthService::EXPIRATION_TIME)
    end

    it 'generates different tokens for different users' do
      token1 = AuthService.generate_token('user1')
      token2 = AuthService.generate_token('user2')
      expect(token1).not_to eq(token2)
    end
  end

  describe '.decode_token' do
    let(:valid_token) { AuthService.generate_token('admin') }

    context 'with valid token' do
      it 'returns the payload hash' do
        payload = AuthService.decode_token(valid_token)
        expect(payload).to be_a(Hash)
        expect(payload['username']).to eq('admin')
      end
    end

    context 'with invalid token' do
      it 'returns nil for malformed token' do
        expect(AuthService.decode_token('invalid.token')).to be_nil
      end

      it 'returns nil for token with wrong signature' do
        fake_token = JWT.encode({ username: 'admin' }, 'wrong_secret', 'HS256')
        expect(AuthService.decode_token(fake_token)).to be_nil
      end

      it 'returns nil for expired token' do
        expired_payload = {
          username: 'admin',
          iat: Time.now.to_i - 7200, # 2 hours ago
          exp: Time.now.to_i - 3600  # 1 hour ago (expired)
        }
        expired_token = JWT.encode(expired_payload, AuthService::JWT_SECRET, AuthService::ALGORITHM)
        expect(AuthService.decode_token(expired_token)).to be_nil
      end

      it 'returns nil for nil token' do
        expect(AuthService.decode_token(nil)).to be_nil
      end
    end
  end

  describe '.token_valid?' do
    let(:valid_token) { AuthService.generate_token('admin') }

    it 'returns true for valid token' do
      expect(AuthService.token_valid?(valid_token)).to be true
    end

    it 'returns false for invalid token' do
      expect(AuthService.token_valid?('invalid.token')).to be false
    end

    it 'returns false for expired token' do
      expired_payload = {
        username: 'admin',
        iat: Time.now.to_i - 7200,
        exp: Time.now.to_i - 3600
      }
      expired_token = JWT.encode(expired_payload, AuthService::JWT_SECRET, AuthService::ALGORITHM)
      expect(AuthService.token_valid?(expired_token)).to be false
    end

    it 'returns false for nil token' do
      expect(AuthService.token_valid?(nil)).to be false
    end
  end

  describe '.extract_username' do
    let(:token) { AuthService.generate_token('testuser') }

    it 'extracts username from valid token' do
      expect(AuthService.extract_username(token)).to eq('testuser')
    end

    it 'returns nil for invalid token' do
      expect(AuthService.extract_username('invalid.token')).to be_nil
    end

    it 'returns nil for nil token' do
      expect(AuthService.extract_username(nil)).to be_nil
    end
  end

  describe 'constants' do
    it 'has correct expiration time' do
      expect(AuthService::EXPIRATION_TIME).to eq(3600)
    end

    it 'uses HS256 algorithm' do
      expect(AuthService::ALGORITHM).to eq('HS256')
    end

    it 'has a JWT secret' do
      expect(AuthService::JWT_SECRET).to be_a(String)
      expect(AuthService::JWT_SECRET).not_to be_empty
    end
  end
end
