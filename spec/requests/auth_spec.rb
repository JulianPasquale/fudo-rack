# frozen_string_literal: true

RSpec.describe AuthController do
  let(:controller) { AuthController.new }

  let(:params) { { username: 'admin', password: 'password' } }
  describe '#call' do
    context 'when request is a POST verb' do
      subject { post '/api/v1/log_in', params.to_json, { 'CONTENT_TYPE' => 'application/json' } }

      context 'with valid credentials' do
        it 'returns success status' do
          subject
          expect(last_response.status).to eq(200)
          expect(last_response.content_type).to eq('application/json')
          response_body = JSON.parse(last_response.body)

          expect(response_body['token']).to be_a(String)
          expect(response_body['token'].split('.').length).to eq(3) # JWT format
          expect(response_body['expires_in']).to eq(3600)

          # Verify the token contains the correct username
          strategy = AuthStrategies::JWTAuth.new
          payload = strategy.decode_token(response_body['token'])
          expect(payload['username']).to eq('admin')
        end
      end

      context 'with invalid credentials' do
        let(:params) { { username: 'admin', password: 'wrong' } }

        it 'returns unauthorized status' do
          subject
          expect(last_response.status).to eq(401)
          response_body = JSON.parse(last_response.body)
          expect(response_body['error']).to eq('Invalid credentials')
        end
      end

      context 'with missing username' do
        let(:params) { { password: 'password' } }

        it 'returns bad request status' do
          subject
          expect(last_response.status).to eq(400)
          response_body = JSON.parse(last_response.body)

          expect(response_body['error']).to eq('Missing username or password')
        end
      end

      context 'with missing password' do
        let(:params) { { username: 'admin' } }

        it 'returns bad request status' do
          subject
          expect(last_response.status).to eq(400)
          response_body = JSON.parse(last_response.body)

          expect(response_body['error']).to eq('Missing username or password')
        end
      end

      context 'with invalid JSON' do
        let(:params) { 'not a json' }

        it 'returns bad request status' do
          subject
          expect(last_response.status).to eq(400)
        end
      end
    end

    context 'with non-POST request' do
      it 'returns method not allowed status' do
        %i[get put delete].each do |verb|
          public_send(verb, '/api/v1/log_in', {}.to_json, { 'CONTENT_TYPE' => 'application/json' })
          expect(last_response.status).to eq(405)
          response_body = JSON.parse(last_response.body)

          expect(response_body['error']).to eq('Method not allowed')
        end
      end
    end
  end
end
