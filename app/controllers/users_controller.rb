# frozen_string_literal: true

require_relative 'application_controller'

class UsersController < ApplicationController
  def profile(request)
    user = current_user(request.env)

    json_ok({ user: user.to_h })
  end
end
