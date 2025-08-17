# frozen_string_literal: true

RSpec.describe Api::V1::ProductsController do
  let(:params) { { name: 'Test Product' } }
  let(:strategy) { AuthStrategies::JWTAuth.new }
  let!(:user) { create(:user, username: 'admin', password: 'password') }
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

          expect(response_body['message']).to eq('Product creation started. It will be available in 5 seconds.')
          expect(response_body['status']).to eq('pending')
        end

        it 'schedules CreateProductJob to create product asynchronously' do
          post '/api/v1/products', params.to_json, {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
          }

          expect(CreateProductJob).to have_enqueued_sidekiq_job.with('product_name' => 'Test Product')

          # Also verify the job is scheduled for the future (approximately 5 seconds)
          scheduled_job = CreateProductJob.jobs.last
          expect(scheduled_job['at']).to be_within(1).of(Time.now.to_f + 5)
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
      context 'when database has products' do
        let!(:first_product) { create(:product, name: 'Product 1') }
        let!(:second_product) { create(:product, name: 'Product 2') }

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
      context 'with non-POST request' do
        it 'returns method not allowed status' do
          %i[put delete].each do |verb|
            public_send(verb, '/api/v1/products', {}.to_json, {
                          'CONTENT_TYPE' => 'application/json',
                          'HTTP_AUTHORIZATION' => "Bearer #{auth_token}"
                        })
            expect(last_response.status).to eq(405)
            response_body = JSON.parse(last_response.body)

            expect(response_body['error']).to eq('Method not allowed')
          end
        end
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
