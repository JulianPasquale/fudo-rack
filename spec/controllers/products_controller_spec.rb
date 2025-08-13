# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ProductsController' do
  let(:auth_payload) { { username: 'admin', password: 'secret' } }
  let(:product_payload) { { name: 'Test Product' } }

  let(:jwt_token) do
    post '/api/auth', auth_payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
    JSON.parse(last_response.body)['token']
  end

  let(:auth_headers) do
    { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}", 'CONTENT_TYPE' => 'application/json' }
  end

  let(:auth_headers_get) do
    { 'HTTP_AUTHORIZATION' => "Bearer #{jwt_token}" }
  end

  describe 'POST /api/products' do
    context 'with valid authentication' do
      it 'creates product asynchronously' do
        post '/api/products', product_payload.to_json, auth_headers
        
        expect(last_response.status).to eq(202)
        response_body = JSON.parse(last_response.body)
        
        expect(response_body).to have_key('id')
        expect(response_body['id']).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
        expect(response_body['status']).to eq('pending')
        expect(response_body['message']).to include('5 seconds')
      end

      it 'creates products with different names' do
        post '/api/products', { name: 'Product 1' }.to_json, auth_headers
        product1_id = JSON.parse(last_response.body)['id']
        
        post '/api/products', { name: 'Product 2' }.to_json, auth_headers
        product2_id = JSON.parse(last_response.body)['id']
        
        expect(product1_id).not_to eq(product2_id)
      end
    end

    context 'with invalid authentication' do
      it 'returns 401 without authorization header' do
        post '/api/products', product_payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'returns 401 with invalid token' do
        headers = { 'HTTP_AUTHORIZATION' => 'Bearer invalid_token', 'CONTENT_TYPE' => 'application/json' }
        post '/api/products', product_payload.to_json, headers
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'returns 401 with malformed authorization header' do
        headers = { 'HTTP_AUTHORIZATION' => 'InvalidFormat token', 'CONTENT_TYPE' => 'application/json' }
        post '/api/products', product_payload.to_json, headers
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid payload' do
      it 'returns 400 for missing name' do
        post '/api/products', {}.to_json, auth_headers
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Name is required')
      end

      it 'returns 400 for empty name' do
        post '/api/products', { name: '' }.to_json, auth_headers
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Name is required')
      end

      it 'returns 400 for null name' do
        post '/api/products', { name: nil }.to_json, auth_headers
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Name is required')
      end

      it 'returns 400 for invalid JSON' do
        post '/api/products', 'invalid json', auth_headers
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Invalid JSON')
      end
    end
  end

  describe 'GET /api/products' do
    context 'with valid authentication' do
      it 'returns empty product list initially' do
        get '/api/products', {}, auth_headers_get
        
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body).to have_key('products')
        expect(response_body['products']).to be_an(Array)
        expect(response_body['products']).to be_empty
      end

      it 'includes completed products after async processing', :slow do
        # Create a product
        post '/api/products', product_payload.to_json, auth_headers
        
        # Wait for async processing
        sleep(6)
        
        # Check products list
        get '/api/products', {}, auth_headers_get
        
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['products']).not_to be_empty
        expect(response_body['products'].first).to have_key('id')
        expect(response_body['products'].first).to have_key('name')
        expect(response_body['products'].first).to have_key('created_at')
        expect(response_body['products'].first['name']).to eq('Test Product')
      end
    end

    context 'with invalid authentication' do
      it 'returns 401 without authorization' do
        get '/api/products'
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'returns 401 with invalid token' do
        get '/api/products', {}, { 'HTTP_AUTHORIZATION' => 'Bearer invalid_token' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end

  describe 'GET /api/products/status' do
    let(:product_id) do
      post '/api/products', product_payload.to_json, auth_headers
      JSON.parse(last_response.body)['id']
    end

    context 'with valid authentication' do
      it 'returns pending status for new product' do
        id = product_id
        get "/api/products/status?id=#{id}", {}, auth_headers_get
        
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['id']).to eq(id)
        expect(response_body['status']).to eq('pending')
        expect(response_body).not_to have_key('product')
      end

      it 'returns completed status after async processing', :slow do
        id = product_id
        sleep(6) # Wait for async processing
        
        get "/api/products/status?id=#{id}", {}, auth_headers_get
        
        expect(last_response.status).to eq(200)
        response_body = JSON.parse(last_response.body)
        expect(response_body['id']).to eq(id)
        expect(response_body['status']).to eq('completed')
        expect(response_body).to have_key('product')
        expect(response_body['product']).to have_key('id')
        expect(response_body['product']).to have_key('name')
        expect(response_body['product']).to have_key('created_at')
      end

      it 'returns 404 for non-existent product' do
        get '/api/products/status?id=non-existent-id', {}, auth_headers_get
        
        expect(last_response.status).to eq(404)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Product not found')
      end

      it 'returns 400 when id parameter is missing' do
        get '/api/products/status', {}, auth_headers_get
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('ID parameter is required')
      end

      it 'returns 400 when id parameter is empty' do
        get '/api/products/status?id=', {}, auth_headers_get
        
        expect(last_response.status).to eq(400)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('ID parameter is required')
      end
    end

    context 'with invalid authentication' do
      it 'returns 401 without authorization' do
        get '/api/products/status?id=test-id'
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end

      it 'returns 401 with invalid token' do
        get '/api/products/status?id=test-id', {}, { 'HTTP_AUTHORIZATION' => 'Bearer invalid_token' }
        
        expect(last_response.status).to eq(401)
        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Unauthorized')
      end
    end
  end
end