# frozen_string_literal: true

require_relative 'application_controller'

class StaticController < ApplicationController
  def openapi(request)
    content = File.read(File.join(__dir__, '..', '..', 'public', 'openapi.yaml'))
    [200, {
      'Content-Type' => 'application/yaml',
      'Cache-Control' => 'no-cache, no-store, must-revalidate'
    }, [content]]
  rescue Errno::ENOENT
    json_not_found('OpenAPI specification not found')
  end

  def authors(request)
    content = File.read(File.join(__dir__, '..', '..', 'public', 'AUTHORS'))
    [200, {
      'Content-Type' => 'text/plain',
      'Cache-Control' => 'public, max-age=86400'  # 24 hours
    }, [content]]
  rescue Errno::ENOENT
    json_not_found('AUTHORS file not found')
  end
end