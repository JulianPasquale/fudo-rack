# frozen_string_literal: true

require_relative 'config/boot'
require 'active_record/tasks/database_tasks'

# Configure database tasks
db_dir = File.expand_path('db', __dir__)

# Load database configuration
database_configurations = {}
%w[development test production].each do |environment|
  database_configurations[environment] = {
    'adapter' => 'sqlite3',
    'database' => File.join(db_dir, "#{environment}.sqlite3"),
    'pool' => 5,
    'timeout' => 5000
  }
end

ActiveRecord::Tasks::DatabaseTasks.tap do |config|
  config.database_configuration = database_configurations
  config.db_dir = db_dir
  config.migrations_paths = [File.join(db_dir, 'migrate')]
  config.root = __dir__
  config.env = ENV['RACK_ENV'] || 'development'
end

namespace :db do
  desc 'Create the database'
  task :create do
    env = ENV['RACK_ENV'] || 'development'
    config = database_configurations[env]

    # Create db directory if it doesn't exist
    FileUtils.mkdir_p(File.dirname(config['database']))

    # Create the database file
    if File.exist?(config['database'])
      puts "Database #{config['database']} already exists."
    else
      FileUtils.touch(config['database'])
      puts "Created database #{config['database']}"
    end
  end

  desc 'Drop the database'
  task :drop do
    env = ENV['RACK_ENV'] || 'development'
    config = database_configurations[env]

    if File.exist?(config['database'])
      File.delete(config['database'])
      puts "Dropped database #{config['database']}"
    else
      puts "Database #{config['database']} does not exist."
    end
  end

  desc 'Migrate the database'
  task :migrate do
    require 'active_record'

    env = ENV['RACK_ENV'] || 'development'
    config = database_configurations[env]

    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::MigrationContext.new(File.join(db_dir, 'migrate')).migrate
    puts 'Database migration completed.'
  end

  desc 'Rollback the database'
  task :rollback do
    require 'active_record'

    env = ENV['RACK_ENV'] || 'development'
    config = database_configurations[env]
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::MigrationContext.new(File.join(db_dir, 'migrate')).rollback(step)
    puts "Database rollback (#{step} step(s)) completed."
  end

  desc 'Show migration status'
  task :version do
    require 'active_record'

    env = ENV['RACK_ENV'] || 'development'
    config = database_configurations[env]

    ActiveRecord::Base.establish_connection(config)
    version = ActiveRecord::MigrationContext.new(File.join(db_dir, 'migrate')).current_version
    puts "Current version: #{version}"
  end

  desc 'Seed the database'
  task :seed do
    require_relative 'db/seeds'
    puts 'Database seeding completed.'
  end

  desc 'Setup the database'
  task setup: %i[create migrate seed] do
    puts 'Database setup completed.'
  end

  desc 'Reset the database'
  task reset: %i[drop create migrate] do
    puts 'Database reset completed.'
  end

  desc 'Prepare test database'
  task 'test:prepare' do
    ENV['RACK_ENV'] = 'test'
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    puts 'Test database prepared.'
  end
end
