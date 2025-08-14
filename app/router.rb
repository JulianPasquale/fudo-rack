# frozen_string_literal: true

require 'addressable/uri'
require 'addressable/template'

# Require all the controller files
app_files = File.expand_path('controllers/**/*.rb', __FILE__)
Dir.glob(app_files).each { |file| require(file) }

class Router
  Route = Struct.new(:method, :path_template, :controller_class, :action) do
    def initialize(method, path_template, controller_class, action)
      super
      @template = Addressable::Template.new(path_template)
    end

    def matches?(request_method, path)
      method.upcase == request_method.upcase && @template.match(path)
    end

    def extract_params(path)
      match = @template.extract(path)
      match ? match.transform_values { |v| Addressable::URI.unescape(v) } : {}
    end
  end

  def initialize
    @routes = []
    @controllers = {}
  end

  def get(path, controller_class:, action:)
    add_route('GET', path:, controller_class:, action:)
  end

  def post(path, controller_class:, action:)
    add_route('POST', path:, controller_class:, action:)
  end

  def put(path, controller_class:, action:)
    add_route('PUT', path:, controller_class:, action:)
  end

  def patch(path, controller_class:, action:)
    add_route('PATCH', path:, controller_class:, action:)
  end

  def delete(path, controller_class:, action:)
    add_route('DELETE', path:, controller_class:, action:)
  end

  def draw(&block)
    instance_eval(&block)
  end

  def call(env)
    request = Rack::Request.new(env)

    # Use addressable to parse the request URL
    uri = Addressable::URI.parse(request.url)
    path = uri.path

    # Find matching route
    route = @routes.find { |r| r.matches?(request.request_method, path) }
    return not_found unless route

    # Extract path parameters and merge with request params
    path_params = route.extract_params(path)
    path_params.each { |key, value| request.params[key] = value }

    # Get controller class and instantiate with request
    controller_class = Object.const_get(route.controller_class)
    controller_instance = controller_class.new(request)

    # Call the controller action
    controller_instance.public_send(route.action)
  rescue NoMethodError => e
    # Log the error for debugging
    puts "Router error: #{e.message}"
    not_found
  end

  private

  def add_route(method, path:, controller_class:, action:)
    # Validate controller class exists at route registration time
    begin
      klass = Object.const_get(controller_class)
    rescue NameError
      raise "Controller class '#{controller_class}' not found. Make sure the controller file is required and the class is defined."
    end

    # Validate action method exists on controller
    unless klass.instance_methods.include?(action.to_sym) || klass.private_instance_methods.include?(action.to_sym)
      raise "Action '#{action}' not found on controller '#{controller_class}'. Available methods: #{klass.instance_methods.grep(/^(?!initialize$)/).join(', ')}"
    end

    # Convert Rails-style :param to Addressable template {param}
    template_path = path.gsub(/:([a-zA-Z_]\w*)/, '{\1}')

    @routes << Route.new(method, template_path, controller_class, action)
  end

  def not_found
    [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not Found"}']]
  end
end
