# frozen_string_literal: true

RSpec.describe AuthController do
  let(:controller) { AuthController.new }

  let(:params) { { username: 'admin', password: 'password' } }
  describe '#call' do
    context 'when request is a POST verb' do
      subject { post '/auth', params.to_json, { 'CONTENT_TYPE' => 'application/json' } }

      context 'with valid credentials' do
        it 'returns success status' do
          subject
          expect(last_response.status).to eq(200)
          expect(last_response.content_type).to eq('application/json')
          response_body = JSON.parse(last_response.body)

          expect(response_body['token']).to be_a(String)
          expect(response_body['token']).to start_with('token_admin_')
          expect(response_body['expires_in']).to eq(3600)
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
          public_send(verb, '/auth')
          expect(last_response.status).to eq(405)
          response_body = JSON.parse(last_response.body)

          expect(response_body['error']).to eq('Method not allowed')
        end
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
