import { apiClient } from './client';

/**
 * Admin Analytics API Client
 * 
 * Endpoints for learning analytics and statistics
 */

export interface SummaryResponse {
  usersTotal: number;
  usersActive7d: number;
  attemptsTotal: number;
  attemptsInRange: number;
  completionsInRange: number;
  avgAccuracyInRange: number;
}

export interface TimeseriesPoint {
  date: string; // YYYY-MM-DD
  attempts: number;
  completions: number;
}

export interface TimeseriesResponse {
  points: TimeseriesPoint[];
}

export interface TopLesson {
  lessonId: string;
  count: number;
}

export interface TopLessonsResponse {
  items: TopLesson[];
}

export interface UserOverview {
  userId: number;
  hearts: {
    current: number;
    max: number;
  };
  streakDays: number;
  unitsCompleted: number;
  totalUnits: number;
  planetsCompleted: number;
  lessonsCompleted: number;
  lastActiveAt: string | null;
}

export interface UserAttempt {
  attemptId: string;
  lessonId: string;
  mode: string;
  score: number | null;
  total: number;
  accuracy: number;
  durationSec: number | null;
  completedAt: string | null;
  startedAt: string;
}

export interface UserAttemptsResponse {
  items: UserAttempt[];
}

/**
 * Admin Analytics API
 */
export const adminAnalyticsApi = {
  /**
   * Get admin summary statistics
   * GET /api/admin/learning/summary?from=YYYY-MM-DD&to=YYYY-MM-DD
   */
  getSummary: async (from?: string, to?: string): Promise<SummaryResponse> => {
    return apiClient.get<SummaryResponse>('/admin/learning/summary', {
      from,
      to,
    });
  },

  /**
   * Get timeseries data for attempts
   * GET /api/admin/learning/timeseries/attempts?from=YYYY-MM-DD&to=YYYY-MM-DD
   */
  getTimeseries: async (from?: string, to?: string): Promise<TimeseriesResponse> => {
    return apiClient.get<TimeseriesResponse>('/admin/learning/timeseries/attempts', {
      from,
      to,
    });
  },

  /**
   * Get top lessons by metric
   * GET /api/admin/learning/top-lessons?metric=attempts|completions&limit=10
   */
  getTopLessons: async (
    metric: 'attempts' | 'completions' = 'attempts',
    limit: number = 10
  ): Promise<TopLessonsResponse> => {
    return apiClient.get<TopLessonsResponse>('/admin/learning/top-lessons', {
      metric,
      limit,
    });
  },

  /**
   * Get user learning overview (admin view)
   * GET /api/admin/learning/users/:userId/overview
   */
  getUserOverview: async (userId: number): Promise<UserOverview> => {
    return apiClient.get<UserOverview>(`/admin/learning/users/${userId}/overview`);
  },

  /**
   * Get user attempts (admin view)
   * GET /api/admin/learning/users/:userId/attempts?limit=50
   */
  getUserAttempts: async (userId: number, limit: number = 50): Promise<UserAttemptsResponse> => {
    return apiClient.get<UserAttemptsResponse>(`/admin/learning/users/${userId}/attempts`, {
      limit,
    });
  },
};

