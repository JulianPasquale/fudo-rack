# frozen_string_literal: true

require 'rack/deflater'
require_relative 'application'
require_relative 'app/middleware/auth_middleware'

app = Rack::Builder.new do
  use Rack::Deflater
  use AuthMiddleware
  run FudoRack::Application.new
end

run app
