# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Running the Application
```bash
# Start development server
bundle exec puma -C config/puma.rb

# Start with automatic reloading (development)
bundle exec rerun -- bundle exec puma -C config/puma.rb
# Or simply
./bin/dev
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
```

## Architecture Overview

### Rack-based Web Application
This is a pure Rack application using `Rack::Builder` for routing without Rails. The main application class (`App`) uses `Rack::URLMap` to define routes and middleware chains.

### Key Architectural Patterns

**Singleton Pattern for Data Storage**: `ProductStore` and `UserStore` use singleton pattern for in-memory data persistence. Data is lost on server restart.

**Strategy Pattern for Authentication**: Auth system uses dependency injection with `BaseStrategy` interface and `JWTAuth` implementation. New auth strategies can be added by implementing the base strategy interface.

**Service Objects**: Business logic is encapsulated in service classes:
- `AuthService` - handles authentication logic
- `Products::CreateService` - handles async product creation
- `ResponseHandler` - standardizes API responses

**Middleware Chain**: Each route has its own middleware stack:
- `JSONValidator` - validates JSON input
- `AuthMiddleware` - handles JWT authentication

### Autoloading with Zeitwerk
The application uses Zeitwerk for automatic class loading. Key configurations in `config/boot.rb`:
- Collapses directory namespaces for controllers, models, middlewares, services
- Custom inflections for `jwt_auth` → `JWTAuth` and `json_validator` → `JSONValidator`
- Eager loading enabled in test environment

### Asynchronous Processing
Product creation is asynchronous using `Concurrent::ScheduledTask` from concurrent-ruby gem. Products become available 5 seconds after creation request.

### Thread Safety Considerations
- Single Puma worker with multiple threads to maintain shared memory for in-memory storage
- Uses concurrent-ruby for thread-safe operations
- Ruby's built-in Hash/Array are not thread-safe, so the app relies on proper synchronization

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
- `id`: UUID string (auto-generated)
- `name`: String (required)
- `created_at`: Timestamp

### User
- `id`: UUID string (auto-generated)  
- `username`: String
- `password_hash`: SHA256 with static salt (simplified for demo)
- `created_at`: Timestamp

## Development Notes

### Memory Storage Limitations
All data is stored in memory using singleton instances. This means:
- Data persists only during server runtime
- Single worker configuration required to maintain data consistency
- Not suitable for production use without external data store

### Rubocop Configuration
Custom rules in `.rubocop.yml`:
- Documentation requirement disabled
- Block length metrics disabled
- Method length/complexity metrics disabled for `app/app.rb` (routing configuration)

### Default User Account
Username and Password are configured in the `.env` file
