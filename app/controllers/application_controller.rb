# frozen_string_literal: true

require 'json'

class ApplicationController
  protected

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
    body = request.body.read
    JSON.parse(body)
  rescue JSON::ParserError
    nil
  end

  def current_user(env)
    env['current_user']
  end
end
