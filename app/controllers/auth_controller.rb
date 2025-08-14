# frozen_string_literal: true

require_relative 'application_controller'
require_relative '../services/auth_service'

class AuthController < ApplicationController
  def login
    return json_bad_request('Invalid JSON') unless params

    username = params['username']
    password = params['password']

    return json_bad_request('Username and password are required') unless username && password

    auth_result = AuthService.authenticate(username, password)

    if auth_result
      # Store user in session (though we're not using sessions in JWT approach)
      # The user will be available in env['current_user'] via middleware
      json_ok({
        token: auth_result[:token],
        type: 'Bearer',
        expires_in: 86400, # 24 hours in seconds
        user: auth_result[:user].to_h
      })
    else
      json_unauthorized('Invalid credentials')
    end
  end
end
