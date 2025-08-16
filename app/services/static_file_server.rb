# frozen_string_literal: true

class StaticFileServer
  def initialize(file_path, content_type, cache_control = nil)
    @file_path = file_path
    @content_type = content_type
    @cache_control = cache_control
  end

  def call(_env)
    if File.exist?(@file_path)
      content = File.read(@file_path)
      headers = { 'Content-Type' => @content_type }
      headers['Cache-Control'] = @cache_control if @cache_control
      [200, headers, [content]]
    else
      [404, { 'Content-Type' => 'text/plain' }, ['File not found']]
    end
  end
end
