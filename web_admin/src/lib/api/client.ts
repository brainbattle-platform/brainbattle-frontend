import axios, { AxiosInstance, AxiosError } from 'axios';
import { API_BASE_URL, ADMIN_API_KEY } from './config';

/**
 * HTTP Client for Admin APIs
 * Automatically includes x-admin-key header for all requests
 */
class ApiClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
        'x-admin-key': ADMIN_API_KEY,
      },
      timeout: 30000, // 30 seconds
    });

    // Response interceptor for error handling
    this.client.interceptors.response.use(
      (response) => response,
      (error: AxiosError) => {
        // Log error in development
        if (process.env.NODE_ENV === 'development') {
          console.error('[API Error]', {
            url: error.config?.url,
            method: error.config?.method,
            status: error.response?.status,
            data: error.response?.data,
          });
        }
        return Promise.reject(error);
      }
    );
  }

  /**
   * GET request
   */
  async get<T = any>(url: string, params?: Record<string, any>): Promise<T> {
    const response = await this.client.get(url, { params });
    // Handle success response wrapper: { success: true, data: {...} }
    return response.data?.data ?? response.data;
  }

  /**
   * POST request
   */
  async post<T = any>(url: string, data?: any): Promise<T> {
    const response = await this.client.post(url, data);
    return response.data?.data ?? response.data;
  }

  /**
   * PUT request
   */
  async put<T = any>(url: string, data?: any): Promise<T> {
    const response = await this.client.put(url, data);
    return response.data?.data ?? response.data;
  }

  /**
   * DELETE request
   */
  async delete<T = any>(url: string): Promise<T> {
    const response = await this.client.delete(url);
    return response.data?.data ?? response.data;
  }
}

// Export singleton instance
export const apiClient = new ApiClient();

