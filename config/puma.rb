# frozen_string_literal: true

# Puma configuration file

# The directory to operate in
directory '/app'

# Set the environment in which the rack's app will run. The value must be a string.
environment ENV.fetch('RACK_ENV', 'development')

# Store the pid of the server in the file at "path".
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch('PORT', 3000)

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RACK_ENV', 'development')

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Workers for production
if ENV['RACK_ENV'] == 'production'
  # Use the maximum number of workers for production
  workers ENV.fetch('WEB_CONCURRENCY', 2)

  # Use the `preload_app!` method when specifying a `workers` number.
  # This directive tells Puma to first boot the application and load code
  # before forking the application. This takes advantage of Copy On Write
  # process behavior so workers use less memory.
  preload_app!

  on_worker_boot do
    # Worker specific setup for Rails 4.1+
    # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  end
else
  # Single mode for development
  workers 0
end

# Bind to all interfaces in development/container environment
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

# Logging
stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true if ENV['RACK_ENV'] == 'production'

# Set up socket location for development
if ENV['RACK_ENV'] == 'development'
  # Enable control app for development (allows restart via pumactl)
  activate_control_app 'tcp://127.0.0.1:9293', { auth_token: 'dev' }
end