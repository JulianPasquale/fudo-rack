# frozen_string_literal: true

require 'json'
require 'forwardable'

class ApplicationController
  def initialize(request)
    @request = request
  end

  protected

  attr_reader :request

  def params
    @params ||= begin
      url_params = @request.params || {}
      body_params = parse_json_body(@request) || {}
      url_params.merge(body_params)
    end
  end

  def json_response(data, status = 200)
    [status, { 'Content-Type' => 'application/json' }, [JSON.generate(data)]]
  end

  def json_ok(data)
    json_response(data, 200)
  end

  def json_created(data)
    json_response(data, 201)
  end

  def json_accepted(data)
    json_response(data, 202)
  end

  def json_bad_request(message)
    json_response({ error: message }, 400)
  end

  def json_unauthorized(message = 'Unauthorized')
    json_response({ error: message }, 401)
  end

  def json_not_found(message = 'Not Found')
    json_response({ error: message }, 404)
  end

  def parse_json_body(request)
    return @parsed_body if defined?(@parsed_body)

    return @parsed_body = {} unless request.body

    body = request.body.read
    request.body.rewind # Reset for potential future reads

    @parsed_body = if body && !body.empty?
      JSON.parse(body)
    else
      {}
    end
  rescue JSON::ParserError
    @parsed_body = nil
  end

  def current_user(env)
    env['current_user']
  end

  def route_params(env)
    env['router.params'] || {}
  end
end
