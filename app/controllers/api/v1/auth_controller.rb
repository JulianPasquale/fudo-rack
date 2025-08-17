# frozen_string_literal: true

module Api
  module V1
    class AuthController
      def initialize(strategy: AuthStrategies::JWTAuth.new)
        @auth_service = AuthService.new(strategy: strategy)
      end

      def call(env)
        request = Rack::Request.new(env)

        return ResponseHandler.error(:method_not_allowed, 'Method not allowed') unless request.post?

        params = request.env['rack.parsed_params'] || {}
        username = params['username']
        password = params['password']

        return ResponseHandler.error(:bad_request, 'Missing username or password') if username.nil? || password.nil?

        auth_result = @auth_service.generate_token(username, password)

        return ResponseHandler.error(:unauthorized, 'Invalid credentials') unless auth_result

        ResponseHandler.json(:ok, { token: auth_result[:token], expires_in: auth_result[:expires_in] })
      end
    end
  end
end
