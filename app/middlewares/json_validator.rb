# frozen_string_literal: true

require 'json'

class JSONValidator
  METHODS_WITH_BODY = %w[POST PUT PATCH].freeze

  def initialize(app, require_json: false, max_size: 1024 * 1024)
    @app = app
    @require_json = require_json
    @max_size = max_size # 1MB default
  end

  def call(env)
    request = Rack::Request.new(env)

    return @app.call(env) unless METHODS_WITH_BODY.include?(request.request_method)

    content_type = request.content_type

    return payload_too_large_response if request.content_length&.to_i&.>(@max_size)

    body = request.body.read
    request.body.rewind

    return not_acceptable_response if @require_json && !json_content_type?(content_type)

    begin
      env['rack.parsed_params'] = JSON.parse(body)
    rescue JSON::ParserError => e
      return malformed_json_response(e.message)
    end

    # Parse params and add to env
    add_merged_params(env, request)
    @app.call(env)
  end

  private

  def json_content_type?(content_type)
    content_type&.include?('application/json')
  end

  def not_acceptable_response
    error_response(406, 'Not Acceptable', 'Content-Type must be application/json')
  end

  def payload_too_large_response
    error_response(413, 'Payload Too Large', "Request body exceeds maximum size of #{@max_size} bytes")
  end

  def malformed_json_response(message)
    error_response(400, 'Bad Request', "Invalid JSON: #{message}")
  end

  def error_response(status, error, message)
    body = JSON.generate({ error: error, message: message })

    [status, { 'Content-Type' => 'application/json' }, [body]]
  end

  def add_merged_params(env, request)
    merged_params = request.params.dup
    json_params = env['rack.parsed_params']
    merged_params.merge!(json_params) if json_params.is_a?(Hash)

    # Add params method to env
    env['rack.parsed_params'] = merged_params
  end
end
