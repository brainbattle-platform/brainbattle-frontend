export type ViolationSeverity = "low" | "medium" | "high" | "critical";
export type ViolationStatus = "pending" | "reviewing" | "resolved" | "rejected";

export type ViolationType =
  | "spam"
  | "harassment"
  | "hate_speech"
  | "nudity"
  | "violence"
  | "copyright"
  | "other";

export interface ViolationRow {
  id: string;

  // Who reported
  reporterId: string;
  reporterName: string;
  reporterUsername: string;
  reporterAvatarUrl?: string;

  // Who got reported
  reportedUserId: string;
  reportedUserName: string;
  reportedUserUsername: string;
  reportedUserAvatarUrl?: string;

  // Content context
  contentType: "video" | "comment" | "post" | "profile" | "message";
  contentId: string;
  contentPreview?: string; // short text snippet
  contentThumbUrl?: string; // optional thumbnail

  type: ViolationType;
  severity: ViolationSeverity;
  status: ViolationStatus;

  createdAt: string;    // ISO
  lastUpdatedAt: string; // ISO

  // Moderation
  assignedTo?: string; // admin/moderator name
  notes?: string;
  strikesAdded?: number;

  evidenceUrls?: string[];
}
