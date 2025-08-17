# frozen_string_literal: true

RSpec.describe 'AUTHORS endpoint' do
  describe 'GET /AUTHORS' do
    subject { get '/AUTHORS' }

    it 'returns success status' do
      subject
      expect(last_response.status).to eq(200)
    end

    it 'sets correct content type for plain text' do
      subject
      expect(last_response.content_type).to eq('text/plain')
    end

    it 'sets 24-hour cache headers' do
      subject
      expect(last_response.headers['Cache-Control']).to eq('max-age=86400')
    end

    it 'returns authors content' do
      subject
      expect(last_response.body.strip).to eq('Julian Pasquale')
    end

    it 'includes content length header' do
      subject
      expect(last_response.headers['Content-Length']).not_to be_nil
      expect(last_response.headers['Content-Length'].to_i).to be > 0
    end

    it 'includes last-modified header' do
      subject
      expect(last_response.headers['Last-Modified']).not_to be_nil
    end

    context 'when using HEAD request' do
      it 'supports HEAD requests with correct headers' do
        head '/AUTHORS'
        expect(last_response.status).to eq(200)
        expect(last_response.headers['Content-Type']).to eq('text/plain')
        expect(last_response.headers['Cache-Control']).to eq('max-age=86400')
        expect(last_response.body).to be_empty
      end
    end
  end
end
