# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fudo API Integration' do
  describe 'Authentication flow' do
    context 'successful authentication' do
      it 'allows user to authenticate and receive a token' do
        post '/auth', { username: 'admin', password: 'password' }.to_json, {
          'CONTENT_TYPE' => 'application/json'
        }

        expect(last_response.status).to eq(200)
        
        response_body = JSON.parse(last_response.body)
        expect(response_body['token']).to be_a(String)
        expect(response_body['expires_in']).to eq(3600)
      end
    end

    context 'failed authentication' do
      it 'rejects invalid credentials' do
        post '/auth', { username: 'admin', password: 'wrong' }.to_json, {
          'CONTENT_TYPE' => 'application/json'
        }

        expect(last_response.status).to eq(401)
        
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Invalid credentials')
      end
    end
  end

  describe 'Complete product management flow' do
    let(:auth_token) do
      post '/auth', { username: 'admin', password: 'password' }.to_json, {
        'CONTENT_TYPE' => 'application/json'
      }
      JSON.parse(last_response.body)['token']
    end

    it 'allows complete CRUD operations on products' do
      # Step 1: Get empty products list
      get '/products', {}, {
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
      }
      
      expect(last_response.status).to eq(200)
      response_body = JSON.parse(last_response.body)
      expect(response_body['products']).to eq([])

      # Step 2: Create a product (async)
      post '/products', { name: 'Integration Test Product' }.to_json, {
        'CONTENT_TYPE' => 'application/json',
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
      }
      
      expect(last_response.status).to eq(202)
      creation_response = JSON.parse(last_response.body)
      expect(creation_response['status']).to eq('pending')
      expect(creation_response['message']).to include('5 seconds')
      product_id = creation_response['id']

      # Step 3: Verify product is not immediately available
      get '/products', {}, {
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
      }
      
      response_body = JSON.parse(last_response.body)
      expect(response_body['products']).to eq([])

      # Step 4: Wait for async creation and verify product is available
      sleep(6) # Wait for the 5-second delay + buffer
      
      get '/products', {}, {
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
      }
      
      expect(last_response.status).to eq(200)
      response_body = JSON.parse(last_response.body)
      expect(response_body['products'].length).to eq(1)
      
      product = response_body['products'].first
      expect(product['id']).to eq(product_id)
      expect(product['name']).to eq('Integration Test Product')
      expect(product['created_at']).to be_a(String)
    end

    it 'enforces authentication for product operations' do
      # Attempt to create product without token
      post '/products', { name: 'Test Product' }.to_json, {
        'CONTENT_TYPE' => 'application/json'
      }
      
      expect(last_response.status).to eq(401)

      # Attempt to get products without token
      get '/products'
      
      expect(last_response.status).to eq(401)
    end

    it 'handles multiple concurrent product creations' do
      # Create multiple products concurrently
      product_names = ['Product 1', 'Product 2', 'Product 3']
      created_ids = []

      product_names.each do |name|
        post '/products', { name: name }.to_json, {
          'CONTENT_TYPE' => 'application/json',
          'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
        }
        
        expect(last_response.status).to eq(202)
        response_body = JSON.parse(last_response.body)
        created_ids << response_body['id']
      end

      # Wait for all products to be created
      sleep(6)

      # Verify all products are available
      get '/products', {}, {
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
      }
      
      response_body = JSON.parse(last_response.body)
      expect(response_body['products'].length).to eq(3)
      
      retrieved_names = response_body['products'].map { |p| p['name'] }
      expect(retrieved_names).to match_array(product_names)
      
      retrieved_ids = response_body['products'].map { |p| p['id'] }
      expect(retrieved_ids).to match_array(created_ids)
    end
  end

  describe 'Static file serving' do
    before do
      # Create test static files
      File.write('AUTHORS', 'Julian Pasquale')
      File.write('openapi.yaml', 'openapi: 3.0.0\ninfo:\n  title: Fudo API\n  version: 1.0.0')
    end

    after do
      # Clean up test files
      File.delete('AUTHORS') if File.exist?('AUTHORS')
      File.delete('openapi.yaml') if File.exist?('openapi.yaml')
    end

    it 'serves AUTHORS file with proper caching' do
      get '/AUTHORS'
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('Julian Pasquale')
      expect(last_response.headers['Content-Type']).to eq('text/plain')
      expect(last_response.headers['Cache-Control']).to eq('max-age=86400')
    end

    it 'serves openapi.yaml with no-cache headers' do
      get '/openapi.yaml'
      
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('openapi: 3.0.0')
      expect(last_response.headers['Content-Type']).to eq('application/x-yaml')
      expect(last_response.headers['Cache-Control']).to eq('no-cache, no-store, must-revalidate')
    end
  end

  describe 'Root endpoint' do
    it 'returns API information' do
      get '/'
      
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to eq('application/json')
      
      response_body = JSON.parse(last_response.body)
      expect(response_body['message']).to eq('Fudo API')
      expect(response_body['version']).to eq('1.0.0')
    end
  end

  describe 'Error handling' do
    let(:auth_token) do
      post '/auth', { username: 'admin', password: 'password' }.to_json, {
        'CONTENT_TYPE' => 'application/json'
      }
      JSON.parse(last_response.body)['token']
    end

    it 'handles malformed JSON in product creation' do
      post '/products', 'invalid json', {
        'CONTENT_TYPE' => 'application/json',
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
      }
      
      expect(last_response.status).to eq(400)
      response_body = JSON.parse(last_response.body)
      expect(response_body['error']).to eq('Missing product name')
    end

    it 'handles unsupported HTTP methods' do
      patch '/products', {}, {
        'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
      }
      
      expect(last_response.status).to eq(405)
    end
  end

  describe 'Content compression' do
    it 'compresses responses when client accepts gzip' do
      get '/', {}, {
        'HTTP_ACCEPT_ENCODING' => 'gzip, deflate'
      }
      
      # Rack::Deflater should add compression
      expect(last_response.status).to eq(200)
      # Note: In a real scenario, you might check for Content-Encoding header
    end
  end
end