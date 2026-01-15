/**
 * API Configuration
 * 
 * Base URL for dou-service (learning/admin APIs)
 * Can be overridden via NEXT_PUBLIC_DOU_API_URL environment variable
 */
export const API_BASE_URL = 
  process.env.NEXT_PUBLIC_DOU_API_URL || 'http://localhost:4003/api';

/**
 * Admin API Key for authentication
 * Can be overridden via NEXT_PUBLIC_ADMIN_API_KEY environment variable
 */
export const ADMIN_API_KEY = 
  process.env.NEXT_PUBLIC_ADMIN_API_KEY || 'dev-admin';

