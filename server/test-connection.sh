#!/bin/bash

echo "Testing the /events endpoint for keep-alive functionality..."
echo "This will monitor the connection for 2 minutes to show keep-alive messages."
echo "Press Ctrl+C to stop."
echo ""

timeout 120 curl -N --http2 -H "Accept: text/event-stream" -H "Cache-Control: no-cache" http://localhost:3000/events 2>/dev/null | while IFS= read -r line; do
    timestamp=$(date '+%H:%M:%S')
    echo "[$timestamp] $line"
done

echo ""
echo "Connection test completed. The server should have sent keep-alive messages every 30 seconds."
