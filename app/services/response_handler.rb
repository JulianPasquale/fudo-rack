# frozen_string_literal: true

require 'json'
require 'rack'

class ResponseHandler
  def self.json(status_symbol, data = {}, headers = {})
    status_code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status_symbol] || status_symbol

    default_headers = { 'Content-Type' => 'application/json' }
    response_headers = default_headers.merge(headers)

    [status_code, response_headers, [JSON.generate(data)]]
  end

  def self.error(status_symbol, message, headers = {})
    json(status_symbol, { error: message }, headers)
  end
end
