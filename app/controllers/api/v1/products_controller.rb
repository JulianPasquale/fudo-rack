# frozen_string_literal: true

module Api
  module V1
    class ProductsController
      def call(env)
        request = Rack::Request.new(env)

        case request.request_method
        when 'POST'
          create(request)
        when 'GET'
          index
        else
          ResponseHandler.error(:method_not_allowed, 'Method not allowed')
        end
      end

      private

      def create(request)
        params = request.env['rack.parsed_params'] || {}
        name = params['name']

        return ResponseHandler.error(:bad_request, 'Missing product name') if name.nil? || name.empty?

        Products::CreateService.new.create(name)
        response = {
          message: 'Product creation started. It will be available in 5 seconds.',
          status: 'pending'
        }
        ResponseHandler.json(:accepted, response)
      end

      def index
        products = Product.all.map(&:to_h)
        ResponseHandler.json(:ok, { products: products })
      end
    end
  end
end
