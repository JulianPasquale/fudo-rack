# frozen_string_literal: true

RSpec.describe 'OpenAPI endpoint' do
  describe 'GET /openai.yaml' do
    subject { get '/openai.yaml' }

    it 'returns success status' do
      subject
      expect(last_response.status).to eq(200)
    end

    it 'sets correct content type for YAML' do
      subject
      expect(last_response.content_type).to eq('application/x-yaml')
    end

    it 'sets no-cache headers' do
      subject
      expect(last_response.headers['Cache-Control']).to eq('no-cache, no-store, must-revalidate')
    end

    it 'returns OpenAPI specification content' do
      subject
      expect(last_response.body).to include('openapi: 3.0.3')
      expect(last_response.body).to include('Fudo Products API')
    end

    it 'includes content length header' do
      subject
      expect(last_response.headers['Content-Length']).not_to be_nil
      expect(last_response.headers['Content-Length'].to_i).to be > 0
    end

    context 'when using HEAD request' do
      it 'supports HEAD requests with correct headers' do
        head '/openai.yaml'
        expect(last_response.status).to eq(200)
        expect(last_response.headers['Content-Type']).to eq('application/x-yaml')
        expect(last_response.headers['Cache-Control']).to eq('no-cache, no-store, must-revalidate')
        expect(last_response.body).to be_empty
      end
    end

    context 'when requesting non-existent static file' do
      it 'falls through to main app routing' do
        get '/nonexistent.txt'
        expect(last_response.status).to eq(404)
        expect(last_response.content_type).to eq('application/json')

        response_body = JSON.parse(last_response.body)
        expect(response_body['error']).to eq('Not Found')
      end
    end
  end
end
