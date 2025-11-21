
import { LucideIcon } from "lucide-react";

import {
  LayoutDashboard,
  Users,
  UserX,
  Search,
  ClipboardList,
  FileCheck,
  Tag,
  BarChart2,
  Dumbbell,
  Medal,
  MessageSquare,
  AlertTriangle,
  ShieldCheck,
  CalendarCheck,
  Check,
  Reply,
  DollarSign,
  Cpu,
  BookOpenCheck,
  Bell,
  CalendarClock,
  Settings,
  Shield,
  LockKeyhole,
  Video,
  Star,
  Sword,
} from "lucide-react";

export interface MenuItem {
  label: string;
  icon: LucideIcon;
  href?: string;
  badge?: number;
  tone?: "info" | "warning" | "danger";
  children?: MenuItem[];
}

export const menu: MenuItem[] = [
  {
    label: "OVERVIEW",
    icon: LayoutDashboard,
    href: "/admin",
  },

  {
    label: "USER MANAGEMENT",
    icon: Users,
    children: [
      { label: "Learners", icon: Users, href: "/admin/users/learners" },
      { label: "Creators & Access Rights", icon: UserX, href: "/admin/users/creators" },
      {
        label: "Violation Reports",
        icon: AlertTriangle,
        href: "/admin/users/violations",
        tone: "danger",
        badge: 12,
      },
      { label: "Search & Filter", icon: Search, href: "/admin/users/search" },
    ],
  },

  {
    label: "LEARNING CONTENT",
    icon: BookOpenCheck,
    children: [
      { label: "AIM Lessons", icon: ClipboardList, href: "/admin/learning/units" },
      { label: "Question Bank", icon: Dumbbell, href: "/admin/learning/questions" },
      { label: "Import / Export", icon: FileCheck, href: "/admin/learning/import-export" },
      { label: "Metadata Tags", icon: Tag, href: "/admin/learning/tags" },
    ],
  },

  {
    label: "VIDEO MODERATION",
    icon: Video,
    children: [
      {
        label: "Pending Review",
        icon: Video,
        href: "/admin/videos/review",
        tone: "warning",
        badge: 8,
      },
      {
        label: "Violations",
        icon: AlertTriangle,
        href: "/admin/videos/violations",
        tone: "danger",
        badge: 4,
      },
      { label: "Interaction Stats", icon: BarChart2, href: "/admin/videos/stats" },
      { label: "Ratings & Reviews", icon: Star, href: "/admin/videos/ratings" },
    ],
  },

  {
    label: "CLAN / GUILD",
    icon: Users,
    children: [
      { label: "Clan List", icon: Users, href: "/admin/clans/list" },
      { label: "Chat History", icon: MessageSquare, href: "/admin/clans/chats" },
      { label: "Blocked Clans", icon: ShieldCheck, href: "/admin/clans/block" },
      { label: "Search Topics", icon: Search, href: "/admin/clans/search" },
    ],
  },

  {
    label: "BATTLE SYSTEM",
    icon: Sword,
    children: [
      { label: "Match History", icon: CalendarCheck, href: "/admin/battles/history" },
      { label: "Flagged Matches", icon: AlertTriangle, href: "/admin/battles/flags" },
      { label: "Battle Question Sets", icon: BookOpenCheck, href: "/admin/battles/questions" },
      { label: "Top Ranking", icon: Medal, href: "/admin/battles/ranking" },
    ],
  },

  {
    label: "SYSTEM ANALYTICS",
    icon: BarChart2,
    children: [
      { label: "Learner Analytics", icon: Users, href: "/admin/analytics/learners" },
      { label: "Revenue & Items", icon: DollarSign, href: "/admin/analytics/revenue" },
      { label: "Time Comparison", icon: CalendarClock, href: "/admin/analytics/compare" },
      { label: "Export Reports", icon: FileCheck, href: "/admin/analytics/export" },
    ],
  },

  {
    label: "SUPPORT & REPORTS",
    icon: MessageSquare,
    children: [
      { label: "All Reports", icon: AlertTriangle, href: "/admin/support/reports" },
      { label: "Processing Status", icon: Check, href: "/admin/support/status" },
      { label: "FAQ", icon: BookOpenCheck, href: "/admin/support/faq" },
      { label: "User Feedback", icon: Reply, href: "/admin/support/feedback" },
    ],
  },

  {
    label: "SYSTEM SETTINGS",
    icon: Settings,
    children: [
      { label: "Roles & Permissions", icon: Shield, href: "/admin/system/roles" },
      { label: "Activity Logs", icon: LockKeyhole, href: "/admin/system/logs" },
      { label: "Backup & Restore", icon: Cpu, href: "/admin/system/backup" },
      { label: "Alert Settings", icon: Bell, href: "/admin/system/alerts" },
    ],
  },
];
