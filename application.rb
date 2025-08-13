# frozen_string_literal: true

require_relative 'app/controllers/auth_controller'
require_relative 'app/controllers/products_controller'
require_relative 'app/controllers/users_controller'

module FudoRack
  class Application
    def initialize
      @auth_controller = AuthController.new
      @products_controller = ProductsController.new
      @users_controller = UsersController.new
    end

    def call(env)
      request = Rack::Request.new(env)

      # Static file serving
      case request.path
      when '/openapi.yaml'
        return serve_openapi
      when '/AUTHORS'
        return serve_authors
      end

      # API routes
      case [request.request_method, request.path]
      when ['POST', '/api/auth']
        @auth_controller.login(request)
      when ['GET', '/api/user/profile']
        @users_controller.profile(request)
      when ['POST', '/api/products']
        @products_controller.create(request)
      when ['GET', '/api/products']
        @products_controller.index(request)
      when ['GET', '/api/products/status']
        @products_controller.status(request)
      else
        [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not Found"}']]
      end
    end

    private

    def serve_openapi
      content = File.read(File.join(__dir__, 'public', 'openapi.yaml'))
      [200, {
        'Content-Type' => 'application/yaml',
        'Cache-Control' => 'no-cache, no-store, must-revalidate'
      }, [content]]
    rescue Errno::ENOENT
      [404, { 'Content-Type' => 'application/json' }, ['{"error":"OpenAPI specification not found"}']]
    end

    def serve_authors
      content = File.read(File.join(__dir__, 'public', 'AUTHORS'))
      [200, {
        'Content-Type' => 'text/plain',
        'Cache-Control' => 'public, max-age=86400'  # 24 hours
      }, [content]]
    rescue Errno::ENOENT
      [404, { 'Content-Type' => 'application/json' }, ['{"error":"AUTHORS file not found"}']]
    end
  end
end
