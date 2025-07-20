# API Security - Authentication Guide

## Overview

The Push Notifications API now supports API key authentication to secure your endpoints from unauthorized access.

## Configuration

### 1. Set API Key

Add your API key to the `.env` file:

```bash
# In server/.env
API_KEY=your-secure-api-key-here
```

**Important:** Use a strong, unique API key in production!

### 2. Generate Secure API Key

You can generate a secure API key using various methods:

```bash
# Method 1: Using OpenSSL
openssl rand -base64 32

# Method 2: Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"

# Method 3: Online generator (use trusted sources only)
# Example result: sk_live_abc123def456ghi789jkl012mno345pqr678stu901vwx234yz
```

## Authentication Methods

The API supports multiple authentication methods:

### 1. X-API-Key Header (Recommended)
```bash
curl -X POST "http://your-server:3000/" \
     -H "Content-Type: application/json" \
     -H "X-API-Key: your-secure-api-key-here" \
     -d '{"title": "Test Notification", "message": "Hello World!"}'
```

### 2. Authorization Bearer Header
```bash
curl -X POST "http://your-server:3000/" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer your-secure-api-key-here" \
     -d '{"title": "Test Notification", "message": "Hello World!"}'
```

### 3. API-Key Header
```bash
curl -X POST "http://your-server:3000/" \
     -H "Content-Type: application/json" \
     -H "API-Key: your-secure-api-key-here" \
     -d '{"title": "Test Notification", "message": "Hello World!"}'
```

### 4. Query Parameter
```bash
curl -X POST "http://your-server:3000/?api_key=your-secure-api-key-here" \
     -H "Content-Type: application/json" \
     -d '{"title": "Test Notification", "message": "Hello World!"}'
```

## Protected Endpoints

The following endpoints require authentication:

- `POST /` - Create notification
- `GET /` - Get all notifications  
- `GET /latest` - Get latest notification

## Public Endpoints

These endpoints do NOT require authentication:

- `GET /health` - Health check
- `GET /events` - SSE connection (optional auth with warnings)

## Android App Configuration

To use authentication with the Android app, you'll need to modify the app to include the API key in requests:

### Option 1: Header Authentication
Add the API key header to your HTTP requests:
```java
// In your Android app
connection.setRequestProperty("X-API-Key", "your-secure-api-key-here");
```

### Option 2: Query Parameter
Append the API key to your connection URL:
```java
// In your Android app
String url = "http://your-server:3000/events?api_key=your-secure-api-key-here";
```

## Error Responses

### Missing API Key
```json
{
  "error": "Authentication required",
  "message": "API key must be provided via X-API-Key header, Authorization: Bearer header, or api_key query parameter"
}
```
**HTTP Status:** 401 Unauthorized

### Invalid API Key
```json
{
  "error": "Authentication failed", 
  "message": "Invalid API key provided"
}
```
**HTTP Status:** 401 Unauthorized

## Security Best Practices

### 1. Strong API Keys
- Use at least 32 characters
- Include letters, numbers, and special characters
- Use a cryptographically secure random generator

### 2. Environment Variables
- Never hardcode API keys in your source code
- Use environment variables or secure configuration files
- Add `.env` to your `.gitignore`

### 3. HTTPS in Production
- Always use HTTPS in production environments
- API keys transmitted over HTTP can be intercepted

### 4. Key Rotation
- Regularly rotate your API keys
- Monitor access logs for suspicious activity
- Revoke compromised keys immediately

### 5. Principle of Least Privilege
- Use different API keys for different applications/environments
- Consider implementing role-based access in the future

## Monitoring

The server logs all authentication attempts:

```
[20/7/2025 19:15:30] INFO Authentication successful for 192.168.1.100
[20/7/2025 19:15:35] ERROR Authentication failed - Invalid API key from 192.168.1.101
[20/7/2025 19:15:40] ERROR Authentication failed - No API key provided from 192.168.1.102
```

## Disabling Authentication

To disable authentication (NOT recommended for production):

```bash
# Comment out or remove the API_KEY from .env
# API_KEY=your-secure-api-key-here
```

The server will log warnings when authentication is disabled:
```
⚠️  WARNING: API Key authentication is DISABLED - set API_KEY environment variable
```

## Testing Authentication

Use the health endpoint to verify authentication status:

```bash
curl http://your-server:3000/health
```

Response includes authentication status:
```json
{
  "status": "healthy",
  "authentication": "enabled",
  ...
}
```
