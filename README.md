# Fudo Rack

This is an alternative version. It setups a SQlite database and uses ActiveRecord (not all the Rails gems, only the ORM). For background processing, we use Sidekiq jobs.

This version provides better scalability than persisting the data in memory since it can be scaled to have multiple workers running at the same time.

## Getting Started

### Requirements

- Ruby 3.4.5
- Bundler gem
- Redis

### Local Development

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Setup database
   ```bash
   bundle exec rake db:create db:migrate
   ```

2. Start the server:
   ```bash
   # Start both worker and web servers
   ./bin/dev

   # Or run these commands in different terminals
   bundle exec puma -C config/puma.rb
   bundle exec sidekiq -r ./config/boot.rb

   ```

3. The API will be available at `http://localhost:3000`

### Docker Compose
The app includes a docker-compose file that a Redis server, the Puma web server and the Sidekiq worker.

1. Build the image:
   ```bash
   docker compose build
   ```

2. Run the container:
   ```bash
   docker compose up
   ```

### Development with Devcontainers

The app also comes with a [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers) setup that can be used from any IDE that supports this feature, or also with the [CLI](https://code.visualstudio.com/docs/devcontainers/devcontainer-cli) commands.

## API Endpoints

### Authentication
This endpoints generates a JWT token when the username and password combination is correct.

```bash
# Login (get JWT token)
curl -X POST http://localhost:3000/api/v1/log_in \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'
```

### Products (requires authentication)
These endpoinsts allow to list and create products.

**Products are stored in memory, this means that everytime you kill or restart the server, the data will be cleared.**

```bash
# Get all products
curl -X GET http://localhost:3000/api/v1/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# Create a product
curl -X POST http://localhost:3000/api/v1/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"name": "Test Product"}'
```

### Static Files
```bash
# OpenAPI specification
curl http://localhost:3000/openapi.yaml

# Authors file
curl http://localhost:3000/AUTHORS
```
