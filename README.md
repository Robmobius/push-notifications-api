
Before installing the Node server, ensure your system has the necessary build tools:

### Ubuntu/Debian Systems
```bash
sudo apt update
sudo apt install build-essential
```

### Alternative: Use the Setup Script
```bash
# Run the included setup script
chmod +x setup.sh
./setup.sh
```

### Why build-essential is needed
The `build-essential` package provides:
- GCC compiler
- Make utility  
- Development libraries
- Other essential build tools

These are required for compiling native Node.js addons that some dependencies may use.

## Server

If you haven't already, install [Node](https://nodejs.org/en/download/prebuilt-binaries).
### Clone the Project

```
git clone git@github.com:viktorholk/push-notifications-api.git
cd push-notifications-api/server
npm i
```
### Start the Server
```
npm run start
```

The app will by default run on port 3000 and the endpoint for the notification events are ``/events``

The port can be changed in the ``server/.env`` file

### API Reference

Replace `127.0.0.1:3000` with your IP and port

#### Push Notification

```http
POST http://127.0.0.1:3000
```
<details><summary>Example Curl</summary>
  
````
curl '127.0.0.1:3000' \
--header 'Content-Type: application/json' \
--data '{
   "title": "Foo Bar Baz!",
    "message": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "url": "http://example.com",
    "icon": "suitcase.png",
    "color": "#1554F0"
}'
````

</details>

|Property|Type|Description|Required|
|---|---|---|---|
|title|String|The title of the notification|**Yes**|
|message|String|The longer text that will be included in the notification|No|
|url|String|Open the URL on notifcation press|No|
|icon|String|24x24 icon file located in `server/src/icons`|No|
|color|String|Customize the notification color. See supported [colors](https://developer.android.com/reference/android/graphics/Color#parseColor(java.lang.String)) |No|

##### Response
`Created 201`

#### Get All Notifications

```http
GET http://127.0.0.1:3000
```

##### Response
````
[
  {
    "title": "Foo Bar Baz!",
    "message": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "url": "http://example.com",
    "icon": "base64encoded...",
    "color": "#1554F0"
  },
  ...
]
````

#### Get The Latest Notification

```http
GET http://127.0.0.1:3000/latest
```

##### Response
````
{
  "title": "Foo Bar Baz!",
  "message": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "url": "http://example.com",
  "icon": "base64encoded...",
  "color": "#1554F0"
}
````


## Common Asked Questions

<details><summary>Notifications are not showing up</summary>

Make sure notifications are enabled in your settings

Settings > Notifications > App notifications

![image](https://github.com/user-attachments/assets/12685adf-7a74-4915-bda6-045175031afb)


</details>

## Issues

Please report issues using [GitHub's issues tab](https://github.com/viktorholk/push-notifications-api/issues).

## License

Push Notifications API is under the [MIT LICENSE](LICENSE).

## 🚀 Recent Updates - Connection Stability Improvements

### Version 1.3.0 - Keep-Alive Enhancement

**Problem Solved:** The Android app connection was dropping after several minutes of inactivity.

**Solution Implemented:**
- ✅ Keep-alive heartbeat system (30-second intervals)
- ✅ Enhanced socket configuration with TCP keep-alive
- ✅ Automatic cleanup of dead connections
- ✅ Extended socket timeout (5 minutes)
- ✅ Graceful shutdown handling

### 🔧 Technical Improvements

#### Keep-Alive Mechanism
```typescript
// Sends keep-alive messages every 30 seconds
const HEARTBEAT_INTERVAL = 30000;
```

#### Enhanced Socket Configuration
- **Socket Timeout:** Extended to 5 minutes (300,000ms)
- **TCP Keep-Alive:** Enabled at socket level with 30-second intervals
- **Nagle's Algorithm:** Disabled for better real-time performance
- **Connection Validation:** Automatic cleanup of broken connections

#### New Endpoints

##### Health Check
```http
GET /health
```
**Response:**
```json
{
  "status": "healthy",
  "uptime": 12345.67,
  "activeConnections": 3,
  "totalNotifications": 42,
  "timestamp": "2025-07-20T18:29:00.000Z"
}
```

### 📊 Connection Management

The server now actively manages connections with:
- **Real-time monitoring** of active connections
- **Automatic cleanup** of dead/broken connections
- **Enhanced logging** for connection events
- **Connection state validation** before sending data

### 🧪 Testing Connection Stability

Use the included test script to verify connection stability:

```bash
cd server
./test-connection.sh
```

This will monitor the `/events` endpoint for 2 minutes and show keep-alive messages.

### 🔍 Monitoring


## System Requirements

Before installing the Node server, ensure your system has the necessary build tools:

### Ubuntu/Debian Systems
```bash
sudo apt update
sudo apt install build-essential
```

### Alternative: Use the Setup Script
```bash
# Run the included setup script
chmod +x setup.sh
./setup.sh
```

### Why build-essential is needed
The `build-essential` package provides:
- GCC compiler
- Make utility  
- Development libraries
- Other essential build tools

These are required for compiling native Node.js addons that some dependencies may use.

#### Server Logs
The server now provides detailed logging:
```
[20/7/2025 18:26:41] INFO Server is running on http://206.189.5.95:3000
[20/7/2025 18:26:41] INFO Heartbeat interval: 30000ms
[20/7/2025 18:27:11] INFO Sent keep-alive to 192.168.1.100
[20/7/2025 18:27:11] INFO Active connections: 2
```

#### Connection Events
- Client connections and disconnections
- Keep-alive message delivery
- Connection cleanup operations
- Error handling and recovery

### 🐛 Bug Fixes

- **Connection Drops:** Resolved through keep-alive heartbeat mechanism
- **Dead Connections:** Automatic cleanup prevents memory leaks
- **Network Timeouts:** Extended socket timeouts handle mobile network behavior
- **Error Handling:** Improved error recovery for network issues

### 📱 Android App Compatibility

The improvements are transparent to the Android app:
- **No app changes required**
- **Maintains existing API compatibility**
- **Enhanced connection stability**
- **Better handling of mobile network conditions**

### 🚀 Performance Improvements

- **Reduced Connection Overhead:** Efficient keep-alive mechanism
- **Better Resource Management:** Automatic cleanup of dead connections
- **Improved Logging:** Better debugging and monitoring capabilities
- **Graceful Shutdown:** Proper resource cleanup on server termination
