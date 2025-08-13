# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AuthController' do
  let(:valid_credentials) { { username: 'admin', password: 'secret' } }
  let(:invalid_credentials) { { username: 'wrong', password: 'wrong' } }

  describe 'POST /api/auth' do
    context 'with valid credentials' do
      it 'returns JWT token and correct response format' do
        post '/api/auth', valid_credentials.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        
        expect(response_body).to have_key('token')
        expect(response_body['token']).to be_a(String)
        expect(response_body['token'].length).to be > 10
        expect(response_body['type']).to eq('Bearer')
        expect(response_body['expires_in']).to eq(86400)
      end

      it 'returns a valid JWT token' do
        post '/api/auth', valid_credentials.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        response_body = JSON.parse(last_response.body)
        token = response_body['token']
        
        # Verify token format (JWT has 3 parts separated by dots)
        expect(token.split('.').length).to eq(3)
      end
    end

    context 'with invalid credentials' do
      it 'returns 401 with error message' do
        post '/api/auth', invalid_credentials.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Invalid credentials')
      end
    end

    context 'with missing credentials' do
      it 'returns 400 when username is missing' do
        post '/api/auth', { password: 'secret' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Username and password are required')
      end

      it 'returns 400 when password is missing' do
        post '/api/auth', { username: 'admin' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Username and password are required')
      end

      it 'returns 400 when both are missing' do
        post '/api/auth', {}.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Username and password are required')
      end
    end

    context 'with invalid JSON' do
      it 'returns 400 for malformed JSON' do
        post '/api/auth', 'invalid json', { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Invalid JSON')
      end
    end

    context 'with missing content type' do
      it 'handles requests without content type' do
        post '/api/auth', valid_credentials.to_json
        
        expect(last_response.status).to be_between(400, 500)
      end
    end
  end
end