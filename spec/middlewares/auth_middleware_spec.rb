# frozen_string_literal: true

RSpec.describe AuthMiddleware do
  let(:env) { Rack::MockRequest.env_for }
  let(:app) { ->(_env) { [200, {}, ['success']] } }

  subject { AuthMiddleware.new(app) }

  describe '#call' do
    context 'when token is valid' do
      let(:valid_token) { 'token_admin_1234567890' }
      let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{valid_token}" } }

      it 'sets the current_user and calls the next app' do
        response = subject.call(env)
        expect(env['current_user']).to eq('admin')
        expect(response).to eq([200, {}, ['success']])
      end
    end

    context 'with token is invalid' do
      context 'when token does not start with token_' do
        let(:invalid_token) { 'invalid_token_format' }
        let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{invalid_token}" } }

        it 'returns 401 unauthorized' do
          response = subject.call(env)
          expect(response[0]).to eq(401)
        end

        it 'returns unauthorized error message' do
          response = subject.call(env)
          body = JSON.parse(response[2].first)
          expect(body['error']).to eq('Unauthorized')
        end

        it 'does not call the next app' do
          expect(app).not_to receive(:call)
          subject.call(env)
        end
      end

      context 'when token has insufficient parts' do
        let(:invalid_token) { 'token_admin' }
        let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{invalid_token}" } }

        it 'returns 401 unauthorized' do
          response = subject.call(env)
          expect(response[0]).to eq(401)
        end
      end
    end

    context 'without Authorization header' do
      let(:env) { {} }

      it 'returns 401 unauthorized' do
        response = subject.call(env)
        expect(response[0]).to eq(401)
      end

      it 'returns unauthorized error message' do
        response = subject.call(env)
        body = JSON.parse(response[2].first)
        expect(body['error']).to eq('Unauthorized')
      end

      it 'does not call the next app' do
        expect(app).not_to receive(:call)
        subject.call(env)
      end
    end

    context 'with non-Bearer authorization' do
      let(:env) { { 'HTTP_AUTHORIZATION' => 'Basic dXNlcjpwYXNz' } }

      it 'returns 401 unauthorized' do
        response = subject.call(env)
        expect(response[0]).to eq(401)
      end

      it 'does not call the next app' do
        expect(app).not_to receive(:call)
        subject.call(env)
      end
    end

    context 'with empty Bearer token' do
      let(:env) { { 'HTTP_AUTHORIZATION' => 'Bearer ' } }

      it 'returns 401 unauthorized' do
        response = subject.call(env)
        expect(response[0]).to eq(401)
      end
    end
  end

  describe 'token validation' do
    let(:middleware) { AuthMiddleware.new(app) }

    describe '#valid_token?' do
      it 'returns true for valid token format' do
        expect(middleware.send(:valid_token?, 'token_admin_1234567890')).to be true
      end

      it 'returns false for token without prefix' do
        expect(middleware.send(:valid_token?, 'admin_1234567890')).to be false
      end

      it 'returns false for token with insufficient parts' do
        expect(middleware.send(:valid_token?, 'token_admin')).to be false
      end

      it 'returns false for empty token' do
        expect(middleware.send(:valid_token?, '')).to be false
      end

      it 'returns false for nil token' do
        expect(middleware.send(:valid_token?, nil)).to be_falsey
      end
    end

    describe '#extract_user_from_token' do
      it 'extracts username from valid token' do
        user = middleware.send(:extract_user_from_token, 'token_admin_1234567890')
        expect(user).to eq('admin')
      end

      it 'extracts username from token with different user' do
        user = middleware.send(:extract_user_from_token, 'token_john_1234567890')
        expect(user).to eq('john')
      end

      it 'returns nil for invalid token format' do
        user = middleware.send(:extract_user_from_token, 'invalid_format')
        expect(user).to be_nil
      end
    end
  end

  describe 'response format' do
    let(:env) { {} }

    it 'returns proper HTTP response array' do
      response = subject.call(env)

      expect(response).to be_an(Array)
      expect(response.length).to eq(3)
      expect(response[0]).to be_a(Integer)  # status
      expect(response[1]).to be_a(Hash)     # headers
      expect(response[2]).to be_an(Array)   # body
    end

    it 'returns JSON content type' do
      response = subject.call(env)
      expect(response[1]['Content-Type']).to eq('application/json')
    end
  end
end
