# frozen_string_literal: true

router.draw do
  # Static file routes
  get '/openapi', controller_class: 'StaticController', action: 'openapi'
  get '/authors', controller_class: 'StaticController', action: 'authors'

  # Authentication routes
  post '/api/auth', controller_class: 'AuthController', action: 'login'

  # User routes
  get '/api/user/profile', controller_class: 'UsersController', action: 'profile'

  # Product routes
  post '/api/products', controller_class: 'ProductsController', action: 'create'
  get '/api/products', controller_class: 'ProductsController', action: 'index'
  get '/api/products/status', controller_class: 'ProductsController', action: 'status'
end
