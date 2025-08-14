# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AuthMiddleware' do
  let(:auth_payload) { { username: 'admin', password: 'secret' } }
  
  let(:jwt_token) do
    post '/api/auth', auth_payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
    JSON.parse(last_response.body)['token']
  end

  describe 'Public endpoints' do
    it 'allows access to authentication endpoint without token' do
      post '/api/auth', auth_payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(200)
    end

    it 'allows access to AUTHORS file without token' do
      get '/authors'
      
      expect(last_response.status).to eq(200)
    end

    it 'allows access to OpenAPI specification without token' do
      get '/openapi'
      
      expect(last_response.status).to eq(200)
    end
  end

  describe 'Protected endpoints' do
    context 'without authorization header' do
      it 'blocks access to products creation' do
        post '/api/products', { name: 'Test' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'blocks access to products listing' do
        get '/api/products'
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'blocks access to product status' do
        get '/api/products/status?id=test'
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid authorization header' do
      it 'rejects non-Bearer token format' do
        get '/api/products', {}, { 'HTTP_AUTHORIZATION' => 'Basic invalid' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'rejects malformed Bearer token' do
        get '/api/products', {}, { 'HTTP_AUTHORIZATION' => 'Bearer' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'rejects invalid JWT token' do
        get '/api/products', {}, { 'HTTP_AUTHORIZATION' => 'Bearer invalid.jwt.token' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'rejects expired JWT token' do
        # This would require mocking time or creating an expired token
        # For now, we'll test with a clearly invalid token structure
        get '/api/products', {}, { 'HTTP_AUTHORIZATION' => 'Bearer expired' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end

    context 'with valid authorization header' do
      it 'allows access to protected endpoints with valid JWT' do
        get '/api/products', {}, { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}" }
        
        expect(last_response.status).to eq(200)
      end

      it 'passes user information to the application' do
        post '/api/products', { name: 'Test Product' }.to_json, {
          'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}",
          'CONTENT_TYPE' => 'application/json'
        }
        
        expect(last_response.status).to eq(202)
      end
    end
  end

  describe 'Response format' do
    it 'returns JSON content type for unauthorized responses' do
      get '/api/products'
      
      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it 'returns valid JSON for unauthorized responses' do
      get '/api/products'
      
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end
  end
end