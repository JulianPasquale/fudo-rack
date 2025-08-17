# Fudo Rack

JWT-authenticated REST API for product management built with Rack for Fudo.

For more details around the technical decisions made in this implementation, checkout the [docs.md](./docs.md) file.

OpenAPI spec are hosted in [Github pages](https://julianpasquale.github.io/fudo-rack/).

## Getting Started

### Requirements

- Ruby 3.4.5
- Bundler gem

### Local Development

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Start the server:
   ```bash
   bundle exec puma -C config/puma.rb
   ```

3. The API will be available at `http://localhost:3000`

### Docker

1. Build the image:
   ```bash
   docker build -t fudo-rack .
   ```

2. Run the container:
   ```bash
   docker run -p 3000:3000 fudo-rack
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
