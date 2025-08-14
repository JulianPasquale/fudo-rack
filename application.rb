# frozen_string_literal: true

# Require all necessary files
require_relative 'app/router'
require_relative 'app/controllers/application_controller'
require_relative 'app/controllers/auth_controller'
require_relative 'app/controllers/products_controller'
require_relative 'app/controllers/users_controller'
require_relative 'app/controllers/static_controller'

module FudoRack
  class Application
    def self.router
      @router ||= begin
        router = Router.new
        # Make router available in routes file scope
        binding.local_variable_set(:router, router)
        eval(File.read(File.join(__dir__, 'config', 'routes.rb')), binding, 'config/routes.rb')
        router
      end
    end

    def call(env)
      # Simple approach: just call the router for everything
      self.class.router.call(env)
    end
  end
end
