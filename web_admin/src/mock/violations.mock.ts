import { ViolationRow } from "@/types/violations.types";

export const mockViolations: ViolationRow[] = [
  {
    id: "v-001",
    reporterId: "u-101",
    reporterName: "Nguyen Van A",
    reporterUsername: "nguyenvana",
    reporterAvatarUrl: "https://i.pravatar.cc/150?img=3",

    reportedUserId: "u-201",
    reportedUserName: "Tran Thi B",
    reportedUserUsername: "tranthib",
    reportedUserAvatarUrl: "https://i.pravatar.cc/150?img=5",

    contentType: "video",
    contentId: "vid-7788",
    contentPreview: "Short video contains hate speech toward group X...",
    contentThumbUrl: "https://picsum.photos/seed/vid7788/200/120",

    type: "hate_speech",
    severity: "critical",
    status: "pending",

    createdAt: "2025-01-20T10:15:00Z",
    lastUpdatedAt: "2025-01-20T10:15:00Z",
    assignedTo: undefined,
    strikesAdded: 0,
    evidenceUrls: ["https://example.com/evidence/1"],
  },

  {
    id: "v-002",
    reporterId: "u-102",
    reporterName: "Le Van C",
    reporterUsername: "levanc",
    reporterAvatarUrl: "https://i.pravatar.cc/150?img=7",

    reportedUserId: "u-202",
    reportedUserName: "Pham Nhat D",
    reportedUserUsername: "phamnhatd",
    reportedUserAvatarUrl: "https://i.pravatar.cc/150?img=9",

    contentType: "comment",
    contentId: "cmt-1299",
    contentPreview: "Buy followers at cheap price!!!",
    type: "spam",
    severity: "low",
    status: "resolved",

    createdAt: "2025-01-18T06:00:00Z",
    lastUpdatedAt: "2025-01-19T09:00:00Z",
    assignedTo: "Mod Hana",
    notes: "Clear spam. Comment removed.",
    strikesAdded: 1,
  },

  {
    id: "v-003",
    reporterId: "u-103",
    reporterName: "Aiko Tanaka",
    reporterUsername: "aiko_sensei",
    reporterAvatarUrl: "https://i.pravatar.cc/150?img=11",

    reportedUserId: "u-203",
    reportedUserName: "Minh Khoa",
    reportedUserUsername: "khoa_englishlab",
    reportedUserAvatarUrl: "https://i.pravatar.cc/150?img=12",

    contentType: "post",
    contentId: "pst-4432",
    contentPreview: "Re-uploaded course PDF without permission.",
    type: "copyright",
    severity: "high",
    status: "reviewing",

    createdAt: "2025-01-19T12:30:00Z",
    lastUpdatedAt: "2025-01-20T02:10:00Z",
    assignedTo: "Admin Linh",
    notes: "Waiting for proof from original creator.",
    strikesAdded: 0,
  },

  {
    id: "v-004",
    reporterId: "u-104",
    reporterName: "Han",
    reporterUsername: "han_bb",
    reporterAvatarUrl: "https://i.pravatar.cc/150?img=14",

    reportedUserId: "u-204",
    reportedUserName: "User X",
    reportedUserUsername: "userx",
    reportedUserAvatarUrl: "https://i.pravatar.cc/150?img=15",

    contentType: "message",
    contentId: "msg-8841",
    contentPreview: "Threatening message sent in DM.",
    type: "harassment",
    severity: "medium",
    status: "pending",

    createdAt: "2025-01-20T08:45:00Z",
    lastUpdatedAt: "2025-01-20T08:45:00Z",
  },
];
