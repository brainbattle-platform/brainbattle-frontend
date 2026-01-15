import { apiClient } from './client';

/**
 * Admin Content API Client
 * 
 * Endpoints for managing learning content (Units, Lessons, Questions)
 */

// ============================================
// Types
// ============================================

export interface Unit {
  id: string; // Prisma PK
  unitId: string; // Business key
  title: string;
  order: number;
  published: boolean;
  createdAt: string;
  updatedAt: string;
  lessons?: Lesson[];
}

export interface Lesson {
  id: string; // Prisma PK
  lessonId: string; // Business key
  unitId: string;
  title: string;
  subtitle?: string;
  order: number;
  published: boolean;
  createdAt: string;
  updatedAt: string;
  questions?: Question[];
}

export interface Question {
  id: string; // Prisma PK
  questionId: string; // Business key
  lessonId: string;
  mode: 'listening' | 'speaking' | 'reading' | 'writing';
  type?: 'MCQ' | 'LISTEN_AND_SELECT' | 'TYPE_ANSWER';
  prompt: string;
  correctAnswer: string;
  explanation?: string;
  hint?: string;
  order: number;
  published: boolean;
  audioAssetId?: string;
  options?: QuestionOption[];
  createdAt: string;
  updatedAt: string;
}

export interface QuestionOption {
  id: string;
  text: string;
  isCorrect: boolean;
  order: number;
}

// ============================================
// DTOs
// ============================================

export interface CreateUnitDto {
  unitId: string;
  title: string;
  order?: number;
  published?: boolean;
}

export interface UpdateUnitDto {
  title?: string;
  order?: number;
  published?: boolean;
}

export interface CreateQuestionDto {
  questionId: string;
  lessonId: string;
  mode: 'listening' | 'speaking' | 'reading' | 'writing';
  type?: string;
  prompt: string;
  correctAnswer: string;
  explanation?: string;
  hint?: string;
  order?: number;
  published?: boolean;
  options?: CreateQuestionOptionDto[];
}

export interface CreateQuestionOptionDto {
  text: string;
  isCorrect: boolean;
  order?: number;
}

export interface UpdateQuestionDto {
  lessonId?: string;
  mode?: 'listening' | 'speaking' | 'reading' | 'writing';
  type?: string;
  prompt?: string;
  correctAnswer?: string;
  explanation?: string;
  hint?: string;
  order?: number;
  published?: boolean;
  options?: CreateQuestionOptionDto[];
}

export interface UpdateOrderDto {
  order: number;
}

// ============================================
// API Client
// ============================================

export const adminContentApi = {
  // ============================================
  // Units
  // ============================================

  /**
   * Create a new unit
   * POST /api/admin/learning/units
   */
  createUnit: async (dto: CreateUnitDto): Promise<Unit> => {
    return apiClient.post<Unit>('/admin/learning/units', dto);
  },

  /**
   * Get all units
   * GET /api/admin/learning/units?publishedOnly=true
   */
  getUnits: async (publishedOnly?: boolean): Promise<Unit[]> => {
    return apiClient.get<Unit[]>('/admin/learning/units', {
      publishedOnly: publishedOnly ? 'true' : undefined,
    });
  },

  /**
   * Get unit by Prisma PK
   * GET /api/admin/learning/units/:id
   */
  getUnitById: async (id: string): Promise<Unit> => {
    return apiClient.get<Unit>(`/admin/learning/units/${id}`);
  },

  /**
   * Get unit by business key
   * GET /api/admin/learning/units/by-unitId/:unitId
   */
  getUnitByUnitId: async (unitId: string): Promise<Unit> => {
    return apiClient.get<Unit>(`/admin/learning/units/by-unitId/${unitId}`);
  },

  /**
   * Update unit by Prisma PK
   * PUT /api/admin/learning/units/:id
   */
  updateUnit: async (id: string, dto: UpdateUnitDto): Promise<Unit> => {
    return apiClient.put<Unit>(`/admin/learning/units/${id}`, dto);
  },

  /**
   * Update unit by business key
   * PUT /api/admin/learning/units/by-unitId/:unitId
   */
  updateUnitByUnitId: async (unitId: string, dto: UpdateUnitDto): Promise<Unit> => {
    return apiClient.put<Unit>(`/admin/learning/units/by-unitId/${unitId}`, dto);
  },

  /**
   * Delete unit by Prisma PK
   * DELETE /api/admin/learning/units/:id
   */
  deleteUnit: async (id: string): Promise<void> => {
    return apiClient.delete(`/admin/learning/units/${id}`);
  },

  /**
   * Delete unit by business key
   * DELETE /api/admin/learning/units/by-unitId/:unitId
   */
  deleteUnitByUnitId: async (unitId: string): Promise<void> => {
    return apiClient.delete(`/admin/learning/units/by-unitId/${unitId}`);
  },

  /**
   * Publish unit
   * POST /api/admin/learning/units/:id/publish
   */
  publishUnit: async (id: string): Promise<Unit> => {
    return apiClient.post<Unit>(`/admin/learning/units/${id}/publish`);
  },

  /**
   * Unpublish unit
   * POST /api/admin/learning/units/:id/unpublish
   */
  unpublishUnit: async (id: string): Promise<Unit> => {
    return apiClient.post<Unit>(`/admin/learning/units/${id}/unpublish`);
  },

  /**
   * Update unit order
   * PUT /api/admin/learning/units/:id/order
   */
  updateUnitOrder: async (id: string, order: number): Promise<Unit> => {
    return apiClient.put<Unit>(`/admin/learning/units/${id}/order`, { order });
  },

  // ============================================
  // Questions
  // ============================================

  /**
   * Create a new question
   * POST /api/admin/learning/questions
   */
  createQuestion: async (dto: CreateQuestionDto): Promise<Question> => {
    return apiClient.post<Question>('/admin/learning/questions', dto);
  },

  /**
   * Get all questions
   * GET /api/admin/learning/questions?lessonId=&mode=&publishedOnly=
   */
  getQuestions: async (params?: {
    lessonId?: string;
    mode?: string;
    publishedOnly?: boolean;
  }): Promise<Question[]> => {
    return apiClient.get<Question[]>('/admin/learning/questions', {
      lessonId: params?.lessonId,
      mode: params?.mode,
      publishedOnly: params?.publishedOnly ? 'true' : undefined,
    });
  },

  /**
   * Get question by Prisma PK
   * GET /api/admin/learning/questions/:id
   */
  getQuestionById: async (id: string): Promise<Question> => {
    return apiClient.get<Question>(`/admin/learning/questions/${id}`);
  },

  /**
   * Get question by business key
   * GET /api/admin/learning/questions/by-questionId/:questionId
   */
  getQuestionByQuestionId: async (questionId: string): Promise<Question> => {
    return apiClient.get<Question>(`/admin/learning/questions/by-questionId/${questionId}`);
  },

  /**
   * Update question by Prisma PK
   * PUT /api/admin/learning/questions/:id
   */
  updateQuestion: async (id: string, dto: UpdateQuestionDto): Promise<Question> => {
    return apiClient.put<Question>(`/admin/learning/questions/${id}`, dto);
  },

  /**
   * Update question by business key
   * PUT /api/admin/learning/questions/by-questionId/:questionId
   */
  updateQuestionByQuestionId: async (questionId: string, dto: UpdateQuestionDto): Promise<Question> => {
    return apiClient.put<Question>(`/admin/learning/questions/by-questionId/${questionId}`, dto);
  },

  /**
   * Delete question by Prisma PK
   * DELETE /api/admin/learning/questions/:id
   */
  deleteQuestion: async (id: string): Promise<void> => {
    return apiClient.delete(`/admin/learning/questions/${id}`);
  },

  /**
   * Delete question by business key
   * DELETE /api/admin/learning/questions/by-questionId/:questionId
   */
  deleteQuestionByQuestionId: async (questionId: string): Promise<void> => {
    return apiClient.delete(`/admin/learning/questions/by-questionId/${questionId}`);
  },

  /**
   * Publish question
   * POST /api/admin/learning/questions/:id/publish
   */
  publishQuestion: async (id: string): Promise<Question> => {
    return apiClient.post<Question>(`/admin/learning/questions/${id}/publish`);
  },

  /**
   * Unpublish question
   * POST /api/admin/learning/questions/:id/unpublish
   */
  unpublishQuestion: async (id: string): Promise<Question> => {
    return apiClient.post<Question>(`/admin/learning/questions/${id}/unpublish`);
  },

  /**
   * Update question order
   * PUT /api/admin/learning/questions/:id/order
   */
  updateQuestionOrder: async (id: string, order: number): Promise<Question> => {
    return apiClient.put<Question>(`/admin/learning/questions/${id}/order`, { order });
  },
};

