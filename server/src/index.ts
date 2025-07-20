import dotenv from 'dotenv';
dotenv.config();

import express, { Request, Response } from 'express';
import cors from "cors";
import ip from "ip";
import { v4 as uuidv4 } from 'uuid';

import Logger from "@/utils/logger";
import LoggerMiddleware from "@/middleware/logger";
import { ClientContext, PushNotification } from '@/types';
import { loadIcon, sendNotifications } from '@/utils';


let notifications: PushNotification[] = [];
let clients: ClientContext[] = [];
let heartbeatInterval: NodeJS.Timeout;

// Keep-alive heartbeat interval (30 seconds)
const HEARTBEAT_INTERVAL = 30000;

function cleanupDeadConnections() {
    const originalCount = clients.length;
    clients = clients.filter(({ req, res }) => {
        return res.writable && !res.destroyed && !req.socket.destroyed;
    });
    
    if (clients.length !== originalCount) {
        Logger.info(`Cleaned up ${originalCount - clients.length} dead connections`);
    }
}

function startHeartbeat() {
    heartbeatInterval = setInterval(() => {
        // Clean up dead connections first
        cleanupDeadConnections();
        
        // Send keep-alive ping to all connected clients
        clients.forEach(({ req, res }, index) => {
            try {
                // Send a keep-alive comment (SSE comments don't trigger events on client)
                res.write(': keep-alive\n\n');
                Logger.info(`Sent keep-alive to ${req.socket?.remoteAddress}`);
            } catch (error) {
                Logger.error(`Failed to send keep-alive to client ${index}: ${error}`);
            }
        });
        
        // Clean up again after sending keep-alives
        cleanupDeadConnections();
        
        Logger.info(`Active connections: ${clients.length}`);
    }, HEARTBEAT_INTERVAL);
}

function connectClient(req: Request, res: Response) {
    // Set headers to keep the connection open
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Headers", "Cache-Control");
    
    // Set socket timeout to prevent premature closing (5 minutes)
    req.socket.setTimeout(300000);
    
    // Disable Nagle's algorithm for better real-time performance
    req.socket.setNoDelay(true);
    
    // Set keep-alive on the socket level
    req.socket.setKeepAlive(true, 30000);

    Logger.info(`${req.socket?.remoteAddress} connected`);
    clients.push({ req, res });

    // Send initial connection confirmation
    res.write("data: {\"type\":\"connected\",\"message\":\"Connected to push notifications\"}\n\n");
    
    // Send a keep-alive comment immediately
    res.write(": connected\n\n");

    req.on("close", () => {
        Logger.info(`${req.socket?.remoteAddress} disconnected`);
        clients = clients.filter(client => client.req !== req);
    });
    
    req.on("error", (error) => {
        Logger.error(`Connection error for ${req.socket?.remoteAddress}: ${error}`);
        clients = clients.filter(client => client.req !== req);
    });

    // Handle client timeout
    req.socket.on('timeout', () => {
        Logger.error(`Socket timeout for ${req.socket?.remoteAddress}`);
        req.socket.destroy();
    });
}

function createNotification(req: Request, res: Response) {
    const { title, message, url, icon, color } = req.body;

    if (!title || title.trim() === "") {
        return res.status(400).send("'title' field is required");
    }

    const notification: PushNotification = {
        id: uuidv4(),
        title,
        message,
        url,
        icon,
        color,
        createdAt: new Date().toLocaleString()
    };

    if (icon) {
        const base64Icon = loadIcon(icon);
        if (base64Icon) {
            notification.icon = base64Icon;
        }
    }

    notifications.push(notification);

    // Clean up dead connections before sending
    cleanupDeadConnections();
    
    // Send the notification to all the connected clients
    sendNotifications(clients, notification);
    
    // Clean up again after sending
    cleanupDeadConnections();

    res.sendResponse(201);
}

function getAllNotifications(_req: Request, res: Response) {
    res.sendResponse(200, notifications);
}

function getLatestNotification(_req: Request, res: Response) {
    const latestNotification = notifications.length ? notifications[notifications.length - 1] : null;

    if (!latestNotification) {
        return res.sendResponse(404);
    }

    res.sendResponse(200, latestNotification);
}

// Health check endpoint
function healthCheck(_req: Request, res: Response) {
    res.sendResponse(200, {
        status: 'healthy',
        uptime: process.uptime(),
        activeConnections: clients.length,
        totalNotifications: notifications.length,
        timestamp: new Date().toISOString()
    });
}

async function main() {
    const app = express();

    const host = process.env.HOST || "0.0.0.0";
    const port = parseInt(process.env.PORT || "3000", 10);

    app.use(cors());
    app.use(express.json());
    app.use(LoggerMiddleware);

    app.post("/", createNotification);
    app.get("/", getAllNotifications);
    app.get("/latest", getLatestNotification);
    app.get("/events", connectClient);
    app.get("/health", healthCheck);

    // Start the heartbeat mechanism
    startHeartbeat();
    
    // Graceful shutdown handling
    process.on('SIGTERM', () => {
        Logger.info('SIGTERM received, shutting down gracefully');
        clearInterval(heartbeatInterval);
        process.exit(0);
    });
    
    process.on('SIGINT', () => {
        Logger.info('SIGINT received, shutting down gracefully');
        clearInterval(heartbeatInterval);
        process.exit(0);
    });

    app.listen(port, host, () => {
        Logger.info(`Server is running on http://${host === "0.0.0.0" ? ip.address() : host}:${port}`);
        Logger.info(`Heartbeat interval: ${HEARTBEAT_INTERVAL}ms`);
    });
}

main();
