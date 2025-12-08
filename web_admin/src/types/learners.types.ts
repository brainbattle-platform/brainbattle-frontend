export type AccountStatus = "active" | "suspended" | "deleted";

export type UserRow = {
  id: string;
  name: string;
  username: string;
  email: string;
  emailVerified: boolean;
  phone?: string;
  avatarUrl?: string;
  gender: "Male" | "Female" | "Other";
  dob?: string; // ISO
  country: string; // e.g. VN, US
  timezone: string; // e.g. Asia/Ho_Chi_Minh
  language: string; // e.g. en, vi
  status: AccountStatus;
  createdAt: string; // ISO datetime
  lastLogin?: string; // ISO datetime
  lastDevice?: string; // "Chrome • Windows"
};
