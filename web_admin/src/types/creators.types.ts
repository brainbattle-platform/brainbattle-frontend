export type CreatorStatus = "active" | "pending" | "suspended" | "deleted";
export type AccessLevel = "basic" | "verified" | "partner";

export type CreatorRow = {
  id: string;
  name: string;
  username: string;
  email: string;
  avatarUrl?: string;

  status: CreatorStatus;
  accessLevel: AccessLevel;
  kycVerified: boolean;

  country: string;
  timezone: string;
  language: string;

  courses: number;
  students: number;
  followers: number;
  avgRating: number; // 0-5
  totalRevenueUsd: number;

  createdAt: string; // ISO
  lastActiveAt?: string; // ISO
  lastDevice?: string;
};
