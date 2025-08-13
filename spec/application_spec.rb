# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Application' do
  describe 'Static file serving' do
    describe 'GET /AUTHORS' do
      it 'returns AUTHORS file with correct content' do
        get '/AUTHORS'
        
        expect(last_response.status).to eq(200)
        expect(last_response.headers['Content-Type']).to eq('text/plain')
        expect(last_response.body).to include('Julian Pasquale')
      end

      it 'sets correct cache headers for AUTHORS file' do
        get '/AUTHORS'
        
        expect(last_response.headers['Cache-Control']).to eq('public, max-age=86400')
      end
    end

    describe 'GET /openapi.yaml' do
      it 'returns OpenAPI specification' do
        get '/openapi.yaml'
        
        expect(last_response.status).to eq(200)
        expect(last_response.headers['Content-Type']).to eq('application/yaml')
        expect(last_response.body).to include('openapi: 3.0.3')
        expect(last_response.body).to include('Fudo Products API')
      end

      it 'sets no-cache headers for OpenAPI file' do
        get '/openapi.yaml'
        
        expect(last_response.headers['Cache-Control']).to eq('no-cache, no-store, must-revalidate')
      end

      it 'contains all required API endpoints' do
        get '/openapi.yaml'
        
        expect(last_response.body).to include('/api/auth')
        expect(last_response.body).to include('/api/products')
        expect(last_response.body).to include('/api/products/status')
      end

      it 'defines authentication scheme' do
        get '/openapi.yaml'
        
        expect(last_response.body).to include('bearerAuth')
        expect(last_response.body).to include('JWT')
      end
    end
  end

  describe 'Unknown routes' do
    it 'returns 404 for GET requests to unknown paths' do
      get '/unknown/path'
      
      expect(last_response.status).to eq(404)
      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Not Found')
    end

    it 'returns 404 for POST requests to unknown paths' do
      post '/unknown/path', {}.to_json, { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(404)
      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Not Found')
    end

    it 'returns 404 for PUT requests to unknown paths' do
      put '/unknown/path', {}.to_json, { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(404)
      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Not Found')
    end

    it 'returns 404 for DELETE requests to unknown paths' do
      delete '/unknown/path'
      
      expect(last_response.status).to eq(404)
      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Not Found')
    end
  end

  describe 'Response format' do
    it 'returns JSON content type for API endpoints' do
      get '/unknown/api/path'
      
      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it 'returns valid JSON for error responses' do
      get '/unknown'
      
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end
  end
end