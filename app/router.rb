# frozen_string_literal: true

require 'addressable/uri'
require 'addressable/template'

# Require all the controller files
app_files = File.expand_path('controllers/**/*.rb', __FILE__)
Dir.glob(app_files).each { |file| require(file) }

class Router
  Route = Struct.new(:method, :path_template, :controller_class, :action) do
    def matches?(request_method, path)
      method.upcase == request_method.upcase && @template.match(path)
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

    route = @routes.find { |route| route.matches?(method, path) }
    return not_found unless route

    # Call the controller action
    controller.new(request).public_send(route.action)
  rescue NoMethodError
    not_found
  end

  private

  def add_route(method, path:, controller_class:, action:)
    # Convert Rails-style :param to Addressable template {param}
    template_path = path.gsub(/:([a-zA-Z_]\w*)/, '{\1}')

    @routes << Route.new(method, template_path, controller_class, action)
  end

  def controller_class(controller_class)
    return @controllers[controller_class] if @controllers[controller_class]

    begin
      klass = Object.const_get(controller_class)
      @controllers[controller_class] = klass.new
    rescue NameError
      nil
    end
  end

  def not_found
    [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not Found"}']]
  end
end
