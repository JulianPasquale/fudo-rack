# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'UsersController' do
  let(:auth_payload) { { username: 'admin', password: 'secret' } }

  let(:jwt_token) do
    post '/api/auth', auth_payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
    JSON.parse(last_response.body)['token']
  end

  let(:auth_headers_get) do
    { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}" }
  end

  describe 'GET /api/user/profile' do
    context 'with valid authentication' do
      it 'returns current user profile' do
        get '/api/user/profile', {}, auth_headers_get
        
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        
        expect(response_body).to have_key('user')
        expect(response_body['user']).to have_key('id')
        expect(response_body['user']).to have_key('username')
        expect(response_body['user']).to have_key('created_at')
        expect(response_body['user']['username']).to eq('admin')
      end

      it 'returns user instance with UUID' do
        get '/api/user/profile', {}, auth_headers_get
        
        response_body = JSON.parse(last_response.body)
        user_id = response_body['user']['id']
        
        # Verify UUID format
        expect(user_id).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
      end

      it 'returns ISO 8601 formatted created_at timestamp' do
        get '/api/user/profile', {}, auth_headers_get
        
        response_body = JSON.parse(last_response.body)
        created_at = response_body['user']['created_at']
        
        # Verify ISO 8601 format (with timezone)
        expect(created_at).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\+00:00|Z)$/)
      end
    end

    context 'with invalid authentication' do
      it 'returns 401 without authorization' do
        get '/api/user/profile'
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'returns 401 with invalid token' do
        get '/api/user/profile', {}, { 'HTTP_AUTHORIZATION' => 'Bearer invalid_token' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end
end