# frozen_string_literal: true

RSpec.describe AuthController do
  let(:controller) { AuthController.new }

  describe '#call' do
    context 'with POST request' do
      context 'with valid credentials' do
        let(:valid_params) { { username: 'admin', password: 'password' } }

        it 'returns 200 status' do
          post '/auth', valid_params.to_json, { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.status).to eq(200)
        end

        it 'returns a token' do
          post '/auth', valid_params.to_json, { 'CONTENT_TYPE' => 'application/json' }
          response_body = JSON.parse(last_response.body)

          expect(response_body['token']).to be_a(String)
          expect(response_body['token']).to start_with('token_admin_')
          expect(response_body['expires_in']).to eq(3600)
        end

        it 'returns JSON content type' do
          post '/auth', valid_params.to_json, { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.content_type).to eq('application/json')
        end
      end

      context 'with invalid credentials' do
        let(:invalid_params) { { username: 'admin', password: 'wrong' } }

        it 'returns 401 status' do
          post '/auth', invalid_params.to_json, { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.status).to eq(401)
        end

        it 'returns error message' do
          post '/auth', invalid_params.to_json, { 'CONTENT_TYPE' => 'application/json' }
          response_body = JSON.parse(last_response.body)

          expect(response_body['error']).to eq('Invalid credentials')
        end
      end

      context 'with missing username' do
        let(:missing_username) { { password: 'password' } }

        it 'returns 400 status' do
          post '/auth', missing_username.to_json, { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.status).to eq(400)
        end

        it 'returns error message' do
          post '/auth', missing_username.to_json, { 'CONTENT_TYPE' => 'application/json' }
          response_body = JSON.parse(last_response.body)

          expect(response_body['error']).to eq('Missing username or password')
        end
      end

      context 'with missing password' do
        let(:missing_password) { { username: 'admin' } }

        it 'returns 400 status' do
          post '/auth', missing_password.to_json, { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.status).to eq(400)
        end

        it 'returns error message' do
          post '/auth', missing_password.to_json, { 'CONTENT_TYPE' => 'application/json' }
          response_body = JSON.parse(last_response.body)

          expect(response_body['error']).to eq('Missing username or password')
        end
      end

      context 'with invalid JSON' do
        it 'returns 400 status' do
          post '/auth', 'invalid json', { 'CONTENT_TYPE' => 'application/json' }
          expect(last_response.status).to eq(400)
        end
      end
    end

    context 'with non-POST request' do
      it 'returns 405 for GET request' do
        get '/auth'
        expect(last_response.status).to eq(405)
      end

      it 'returns 405 for PUT request' do
        put '/auth'
        expect(last_response.status).to eq(405)
      end

      it 'returns 405 for DELETE request' do
        delete '/auth'
        expect(last_response.status).to eq(405)
      end

      it 'returns method not allowed error message' do
        get '/auth'
        response_body = JSON.parse(last_response.body)

        expect(response_body['error']).to eq('Method not allowed')
      end
    end
  end

  describe 'token generation' do
    let(:controller) { AuthController.new }

    it 'generates unique tokens for different users' do
      allow(Time).to receive(:now).and_return(Time.at(1_234_567_890))

      token1 = controller.send(:generate_token, 'user1')
      token2 = controller.send(:generate_token, 'user2')

      expect(token1).to eq('token_user1_1234567890')
      expect(token2).to eq('token_user2_1234567890')
      expect(token1).not_to eq(token2)
    end

    it 'includes timestamp in token' do
      freeze_time = Time.at(1_234_567_890)
      allow(Time).to receive(:now).and_return(freeze_time)

      token = controller.send(:generate_token, 'admin')
      expect(token).to include(freeze_time.to_i.to_s)
    end
  end
end
