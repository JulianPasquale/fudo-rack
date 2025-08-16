# frozen_string_literal: true

RSpec.describe ProductsController do
  let(:params) { { name: 'Test Product' } }
  let(:strategy) { AuthStrategies::JWTAuth.new }
  let(:user) { User.new(username: 'admin', password: 'password') }
  let(:auth_token) { strategy.generate_token(user) }

  describe '#call' do
    context 'when request is a POST verb' do
      context 'when product name is provided' do
        it 'returns an accepted status' do
          post '/api/v1/products', params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
          expect(last_response.status).to eq(202)
          response_body = JSON.parse(last_response.body)

          expect(response_body['id']).to be_a(String)
          expect(response_body['message']).to eq('Product creation started. It will be available in 5 seconds.')
          expect(response_body['status']).to eq('pending')
        end

        it 'calls Products::CreateService to create product asynchronously' do
          service_instance = instance_double(Products::CreateService)
          expect(Products::CreateService).to receive(:new).and_return(service_instance)
          expect(service_instance).to receive(:create).with('Test Product').and_return(SecureRandom.uuid)

          post '/api/v1/products', params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
        end
      end

      context 'when product name is not provided' do
        let(:params) { {} }

        it 'returns bad_format status' do
          post '/api/v1/products', params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
          expect(last_response.status).to eq(400)
          response_body = JSON.parse(last_response.body)
          expect(response_body['error']).to eq('Missing product name')
        end
      end

      context 'when product name is empty' do
        let(:params) { { name: '' } }

        it 'returns 400 status' do
          post '/api/v1/products', params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
          expect(last_response.status).to eq(400)
          response_body = JSON.parse(last_response.body)
          expect(response_body['error']).to eq('Missing product name')
        end
      end

      context 'when JSON is invalid' do
        it 'returns 400 status' do
          post '/api/v1/products', 'invalid json', {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
          expect(last_response.status).to eq(400)
        end
      end
    end

    context 'when request is a GET verb' do
      context 'when store has products' do
        let(:first_product) { Product.new(name: 'Product 1') }
        let(:second_product) { Product.new(name: 'Product 2') }

        before do
          allow(ProductStore.instance).to(receive(:products).and_return([first_product, second_product]))
        end

        it 'returns 200 status' do
          get '/api/v1/products', {}, {
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
          expect(last_response.status).to eq(200)
        end

        it 'returns all products as JSON' do
          get '/api/v1/products', {}, {
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
          response_body = JSON.parse(last_response.body)

          expect(response_body['products']).to be_an(Array)
          expect(response_body['products'].length).to eq(2)

          product_names = response_body['products'].map { |p| p['name'] }
          expect(product_names).to include('Product 1', 'Product 2')
        end

        it 'returns products with correct structure' do
          get '/api/v1/products', {}, {
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
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
          get '/api/v1/products', {}, {
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }
          response_body = JSON.parse(last_response.body)

          expect(response_body['products']).to eq([])
        end
      end
    end

    context 'with unsupported HTTP method' do
      it 'returns method not allowed for PUT request' do
        put '/api/v1/products', {}, {
          'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
        }
        expect(last_response.status).to eq(405)
      end

      it 'returns method not allowed for DELETE request' do
        delete '/api/v1/products', {}, {
          'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
        }
        expect(last_response.status).to eq(405)
      end

      it 'returns method not allowed error message' do
        put '/api/v1/products', {}, {
          'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
        }
        response_body = JSON.parse(last_response.body)

        expect(response_body['error']).to eq('Method not allowed')
      end
    end

    context 'without authorization' do
      it 'returns unauthorized for POST request' do
        post '/api/v1/products', { name: 'Test' }.to_json, {
          'CONTENT_TYPE' => 'application/json'
        }
        expect(last_response.status).to eq(401)
      end

      it 'returns unauthorized for GET request' do
        get '/api/v1/products'
        expect(last_response.status).to eq(401)
      end
    end
  end
end
