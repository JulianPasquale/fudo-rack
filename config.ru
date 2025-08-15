# frozen_string_literal: true

require_relative 'app'
require 'dotenv'

# Load environment variables
Dotenv.load

run App.new
