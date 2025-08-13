# frozen_string_literal: true

require 'rack/deflater'
require_relative "application"
require_relative "app/middleware/auth_middleware"

# Add gzip compression middleware
use Rack::Deflater, include: %w[application/json text/plain text/html], if: lambda { |env, status, headers, body|
  env['HTTP_ACCEPT_ENCODING'] =~ /gzip/
}

# Add authentication middleware
use AuthMiddleware

run Application.new
