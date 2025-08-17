# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Database Setup
```bash
# Setup database (create, migrate, seed)
bundle exec rake db:setup

# Create database
bundle exec rake db:create

# Run migrations
bundle exec rake db:migrate

# Seed database with default admin user
bundle exec rake db:seed

# Reset database (drop, create, migrate)
bundle exec rake db:reset

# Prepare test database
bundle exec rake db:test:prepare

# Check migration status
bundle exec rake db:version
```

### Running the Application
```bash
# Start development server
bundle exec puma -C config/puma.rb

# Start with automatic reloading (development)
bundle exec rerun -- bundle exec puma -C config/puma.rb
# Or simply
./bin/dev

# Start with foreman (runs app, worker, and redis)
bundle exec foreman start
```

### Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/requests/auth_spec.rb

# Run specific test
bundle exec rspec spec/requests/auth_spec.rb:12
```

### Code Quality
```bash
# Run linter
bundle exec rubocop

# Auto-fix linting issues
bundle exec rubocop -a

# Run only safe auto-fixes
bundle exec rubocop --safe-auto-correct
```

### Docker
```bash
# Build image
docker build -t fudo-rack .

# Run container
docker run -p 3000:3000 fudo-rack

# Run with docker-compose (app, worker, redis)
docker-compose up
```

## Architecture Overview

### Rack-based Web Application
This is a pure Rack application using `Rack::Builder` for routing without Rails. The main application class (`App`) uses `Rack::URLMap` to define routes and middleware chains.

### Key Architectural Patterns

**ActiveRecord with SQLite**: Uses ActiveRecord ORM with SQLite database for data persistence. Database-backed models ensure data survives server restarts.

**Strategy Pattern for Authentication**: Auth system uses dependency injection with `BaseStrategy` interface and `JWTAuth` implementation. New auth strategies can be added by implementing the base strategy interface.

**Service Objects**: Business logic is encapsulated in service classes:
- `AuthService` - handles authentication logic
- `Products::CreateService` - handles async product creation with Sidekiq
- `ResponseHandler` - standardizes API responses

**Background Jobs with Sidekiq**: Asynchronous processing using Sidekiq for background job processing with Redis as the message broker.

**Middleware Chain**: Each route has its own middleware stack:
- `JSONValidator` - validates JSON input
- `AuthMiddleware` - handles JWT authentication

### Autoloading with Zeitwerk
The application uses Zeitwerk for automatic class loading. Key configurations in `config/boot.rb`:
- Collapses directory namespaces for controllers, models, middlewares, services, jobs
- Custom inflections for `jwt_auth` → `JWTAuth` and `json_validator` → `JSONValidator`
- Eager loading enabled in test environment

### Asynchronous Processing
Product creation is asynchronous using Sidekiq background jobs. Products become available 5 seconds after creation request via `CreateProductJob`.

## API Structure

**Base URL**: `http://localhost:3000`

**Authentication**: JWT Bearer tokens obtained from `/api/v1/log_in`

**Endpoints**:
- `POST /api/v1/log_in` - Get JWT token (username: "admin", password: "password")
- `GET /api/v1/products` - List all products (requires auth)
- `POST /api/v1/products` - Create product asynchronously (requires auth)
- `GET /openapi.yaml` - OpenAPI specification
- `GET /AUTHORS` - Static authors file

## Data Models

### Product
- `id`: Integer (auto-incrementing primary key)
- `name`: String (required)
- `created_at`: Timestamp
- `updated_at`: Timestamp

### User
- `id`: Integer (auto-incrementing primary key)
- `username`: String (unique, required)
- `password_hash`: BCrypt hash
- `created_at`: Timestamp
- `updated_at`: Timestamp

### Background Jobs
- `CreateProductJob`: Sidekiq job for asynchronous product creation

## Development Notes

### Database Storage
All data is stored in SQLite database with ActiveRecord ORM:
- Data persists across server restarts
- Supports multiple workers and processes
- Migrations manage schema changes
- Suitable for development and small production deployments

### Rubocop Configuration
Custom rules in `.rubocop.yml`:
- Documentation requirement disabled
- Block length metrics disabled
- Method length/complexity metrics disabled for `app/app.rb` (routing configuration)

### Default User Account
Username and Password are configured in the `.env` file
