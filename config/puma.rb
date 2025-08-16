# frozen_string_literal: true

# Puma configuration file. Considering the Products and Users data is stored in memory, this config
# only spins up one thread to make sure we get consistent data responses.

directory '/app'
environment ENV.fetch('RACK_ENV', 'development')
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

threads_count = 5
threads threads_count, threads_count

port ENV.fetch('PORT', 3000)
environment ENV.fetch('RACK_ENV', 'development')
workers 0

# Bind to all interfaces in development/container environment
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"
