# Fudo Rack API

A Rack-based JSON API that implements asynchronous product management with JWT authentication.

## Features

- JWT-based authentication
- Asynchronous product creation (5-second delay)
- Product listing and status checking
- Gzip compression support
- OpenAPI specification
- Dockerized deployment

## API Endpoints

- `POST /api/auth` - Authentication (get JWT token)
- `POST /api/products` - Create product asynchronously 
- `GET /api/products` - List all completed products
- `GET /api/products/status?id=<product_id>` - Check product status
- `GET /openapi.yaml` - OpenAPI specification
- `GET /AUTHORS` - Author information

## Setup and Running

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

## Usage Examples

### 1. Authentication
```bash
curl -X POST http://localhost:3000/api/auth \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "secret"}'
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "type": "Bearer",
  "expires_in": 86400
}
```

### 2. Create Product (Asynchronous)
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"name": "Laptop"}'
```

Response:
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "status": "pending",
  "message": "Product creation started. It will be available in 5 seconds."
}
```

### 3. Check Product Status
```bash
curl "http://localhost:3000/api/products/status?id=123e4567-e89b-12d3-a456-426614174000" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. List Products
```bash
curl http://localhost:3000/api/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Architecture

- **Middleware**: Authentication handled by `AuthMiddleware`
- **Controllers**: Separate controllers for auth and products
- **Services**: Business logic in service classes
- **Models**: Simple product model with in-memory storage

## Authentication

Uses JWT tokens with 24-hour expiration. Default credentials:
- Username: `admin`
- Password: `secret`
