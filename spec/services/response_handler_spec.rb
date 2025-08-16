# frozen_string_literal: true

RSpec.describe ResponseHandler do
  describe '.json' do
    it 'creates a JSON response with symbol status' do
      response = ResponseHandler.json(:ok, { message: 'Success' })

      expect(response).to eq([200, { 'Content-Type' => 'application/json' }, ['{"message":"Success"}']])
    end

    it 'creates a JSON response with numeric status' do
      response = ResponseHandler.json(201, { id: 123 })

      expect(response).to eq([201, { 'Content-Type' => 'application/json' }, ['{"id":123}']])
    end

    it 'merges custom headers' do
      response = ResponseHandler.json(:ok, {}, { 'X-Custom' => 'value' })

      expect(response).to eq([200, { 'Content-Type' => 'application/json', 'X-Custom' => 'value' }, ['{}']])
    end
  end

  describe '.error' do
    it 'creates an error response' do
      response = ResponseHandler.error(:bad_request, 'Invalid input')

      expect(response).to eq([400, { 'Content-Type' => 'application/json' }, ['{"error":"Invalid input"}']])
    end
  end
end
