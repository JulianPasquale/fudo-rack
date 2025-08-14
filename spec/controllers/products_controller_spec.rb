# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsController do
  let(:controller) { ProductsController.new }
  let(:store) { ProductStore.instance }

  describe '#call' do
    context 'with POST request' do
      context 'with valid product data' do
        let(:valid_params) { { name: 'Test Product' } }

        it 'returns 202 status' do
          post '/products', valid_params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          expect(last_response.status).to eq(202)
        end

        it 'returns product creation response' do
          post '/products', valid_params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          response_body = JSON.parse(last_response.body)
          
          expect(response_body['id']).to be_a(String)
          expect(response_body['message']).to eq('Product creation started. It will be available in 5 seconds.')
          expect(response_body['status']).to eq('pending')
        end

        it 'calls ProductStore to add product asynchronously' do
          expect(store).to receive(:add_product_async).and_call_original

          post '/products', valid_params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
        end
      end

      context 'with missing product name' do
        let(:invalid_params) { {} }

        it 'returns 400 status' do
          post '/products', invalid_params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          expect(last_response.status).to eq(400)
        end

        it 'returns error message' do
          post '/products', invalid_params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          response_body = JSON.parse(last_response.body)
          
          expect(response_body['error']).to eq('Missing product name')
        end
      end

      context 'with empty product name' do
        let(:empty_name_params) { { name: '' } }

        it 'returns 400 status' do
          post '/products', empty_name_params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          expect(last_response.status).to eq(400)
        end
      end

      context 'with invalid JSON' do
        it 'returns 400 status' do
          post '/products', 'invalid json', {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          expect(last_response.status).to eq(400)
        end
      end
    end

    context 'with GET request' do
      context 'with existing products' do
        let(:product1) { Product.new(name: 'Product 1') }
        let(:product2) { Product.new(name: 'Product 2') }

        before do
          # Add products directly to store for testing
          products_hash = store.instance_variable_get(:@products)
          products_hash[product1.id] = product1
          products_hash[product2.id] = product2
        end

        it 'returns 200 status' do
          get '/products', {}, {
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          expect(last_response.status).to eq(200)
        end

        it 'returns all products as JSON' do
          get '/products', {}, {
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          response_body = JSON.parse(last_response.body)
          
          expect(response_body['products']).to be_an(Array)
          expect(response_body['products'].length).to eq(2)
          
          product_names = response_body['products'].map { |p| p['name'] }
          expect(product_names).to include('Product 1', 'Product 2')
        end

        it 'returns products with correct structure' do
          get '/products', {}, {
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          response_body = JSON.parse(last_response.body)
          product = response_body['products'].first
          
          expect(product).to have_key('id')
          expect(product).to have_key('name')
          expect(product).to have_key('created_at')
        end
      end

      context 'with no products' do
        it 'returns empty products array' do
          get '/products', {}, {
            'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
          }
          response_body = JSON.parse(last_response.body)
          
          expect(response_body['products']).to eq([])
        end
      end
    end

    context 'with unsupported HTTP method' do
      it 'returns 405 for PUT request' do
        put '/products', {}, {
          'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
        }
        expect(last_response.status).to eq(405)
      end

      it 'returns 405 for DELETE request' do
        delete '/products', {}, {
          'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
        }
        expect(last_response.status).to eq(405)
      end

      it 'returns method not allowed error message' do
        put '/products', {}, {
          'HTTP_AUTHORIZATION' => 'Bearer token_admin_1234567890'
        }
        response_body = JSON.parse(last_response.body)
        
        expect(response_body['error']).to eq('Method not allowed')
      end
    end

    context 'without authorization' do
      it 'returns 401 for POST request' do
        post '/products', { name: 'Test' }.to_json, {
          'CONTENT_TYPE' => 'application/json'
        }
        expect(last_response.status).to eq(401)
      end

      it 'returns 401 for GET request' do
        get '/products'
        expect(last_response.status).to eq(401)
      end
    end
  end
end