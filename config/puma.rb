# frozen_string_literal: true

environment ENV.fetch('RACK_ENV', 'development')

pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

max_threads_count = ENV.fetch('MAX_THREADS') { 3 }
min_threads_count = ENV.fetch('MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Use clustered mode in production
if ENV['RACK_ENV'] == 'production'
  worker_count = ENV.fetch('WEB_CONCURRENCY', 1).to_i
  workers worker_count if worker_count > 1
end

bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"
