# frozen_string_literal: true

RSpec.describe AuthMiddleware do
  let(:app) { ->(_env) { [200, {}, ['success']] } }
  subject { AuthMiddleware.new(app) }

  describe '#call' do
    context 'when token is valid' do
      let(:valid_token) { AuthService.generate_token('admin') }
      let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{valid_token}" } }

      it 'sets the current_user and calls the next app' do
        response = subject.call(env)
        expect(env['current_user']).to eq('admin')
        expect(response).to eq([200, {}, ['success']])
      end
    end

    context 'when token is invalid' do
      context 'with malformed JWT token' do
        let(:invalid_token) { 'invalid.jwt.token' }
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

      context 'with expired JWT token' do
        let(:expired_token) do
          expired_payload = {
            username: 'admin',
            iat: Time.now.to_i - 7200,
            exp: Time.now.to_i - 3600
          }
          JWT.encode(expired_payload, AuthService::JWT_SECRET, AuthService::ALGORITHM)
        end
        let(:env) { { 'HTTP_AUTHORIZATION' => "Bearer #{expired_token}" } }

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
