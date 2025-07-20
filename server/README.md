
## 🔐 API Security

### Authentication

The API now supports optional API key authentication for enhanced security:

#### Setup API Key
```bash
# Add to server/.env
API_KEY=your-secure-api-key-here
```

#### Generate Secure API Key
```bash
# Using OpenSSL
openssl rand -base64 32

# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

#### Usage Examples
```bash
# Using X-API-Key header (recommended)
curl -X POST "http://your-server:3000/" \
     -H "Content-Type: application/json" \
     -H "X-API-Key: your-secure-api-key-here" \
     -d '{"title": "Test", "message": "Hello!"}'

# Using Authorization Bearer
curl -X POST "http://your-server:3000/" \
     -H "Authorization: Bearer your-secure-api-key-here" \
     -d '{"title": "Test", "message": "Hello!"}'

# Using query parameter
curl "http://your-server:3000/?api_key=your-secure-api-key-here"
```

#### Protected Endpoints
- `POST /` - Create notification (requires auth)
- `GET /` - Get all notifications (requires auth)
- `GET /latest` - Get latest notification (requires auth)

#### Public Endpoints
- `GET /health` - Health check (no auth required)
- `GET /events` - SSE connection (optional auth)

For detailed authentication documentation, see [`server/API_SECURITY.md`](server/API_SECURITY.md).

