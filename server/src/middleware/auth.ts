import { Request, Response, NextFunction } from 'express';
import Logger from '@/utils/logger';

// Extend Express Request type to include API key
declare global {
    namespace Express {
        interface Request {
            apiKey?: string;
        }
    }
}

/**
 * Authentication middleware for API key validation
 * Supports multiple authentication methods:
 * 1. X-API-Key header
 * 2. Authorization: Bearer <token>
 * 3. API-Key header
 * 4. Query parameter: ?api_key=<token>
 */
export default function authMiddleware(req: Request, res: Response, next: NextFunction) {
    const configuredApiKey = process.env.API_KEY;
    
    // If no API key is configured, log warning and allow access
    if (!configuredApiKey) {
        Logger.error('WARNING: No API_KEY configured in environment variables. API is unsecured!');
        return next();
    }
    
    // Extract API key from various sources
    const apiKey = 
        req.headers['x-api-key'] as string ||
        req.headers['api-key'] as string ||
        (req.headers.authorization?.startsWith('Bearer ') ? 
            req.headers.authorization.substring(7) : undefined) ||
        req.query.api_key as string;
    
    // Check if API key is provided
    if (!apiKey) {
        Logger.error(`Authentication failed - No API key provided from ${req.ip}`);
        return res.status(401).json({
            error: 'Authentication required',
            message: 'API key must be provided via X-API-Key header, Authorization: Bearer header, or api_key query parameter'
        });
    }
    
    // Validate API key
    if (apiKey !== configuredApiKey) {
        Logger.error(`Authentication failed - Invalid API key from ${req.ip}`);
        return res.status(401).json({
            error: 'Authentication failed',
            message: 'Invalid API key provided'
        });
    }
    
    // Store API key in request for potential future use
    req.apiKey = apiKey;
    
    Logger.info(`Authentication successful for ${req.ip}`);
    next();
}

/**
 * Optional authentication middleware - allows access without API key but logs warnings
 */
export function optionalAuthMiddleware(req: Request, res: Response, next: NextFunction) {
    const configuredApiKey = process.env.API_KEY;
    
    if (!configuredApiKey) {
        return next();
    }
    
    const apiKey = 
        req.headers['x-api-key'] as string ||
        req.headers['api-key'] as string ||
        (req.headers.authorization?.startsWith('Bearer ') ? 
            req.headers.authorization.substring(7) : undefined) ||
        req.query.api_key as string;
    
    if (!apiKey) {
        Logger.error(`WARNING: Unauthenticated access to ${req.path} from ${req.ip}`);
    } else if (apiKey !== configuredApiKey) {
        Logger.error(`WARNING: Invalid API key used for ${req.path} from ${req.ip}`);
    } else {
        req.apiKey = apiKey;
        Logger.info(`Authenticated access to ${req.path} from ${req.ip}`);
    }
    
    next();
}
