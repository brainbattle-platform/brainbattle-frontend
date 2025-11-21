import {
  PlayCircle,
  ShieldAlert,
  ClipboardList,
  AlertTriangle,
} from "lucide-react";


export const trendBrand = {
  "7d": [
    { day: "Mon", display: 7.8, presence: 68 },
    { day: "Tue", display: 8.0, presence: 70 },
    { day: "Wed", display: 8.2, presence: 71 },
    { day: "Thu", display: 8.1, presence: 72 },
    { day: "Fri", display: 8.3, presence: 73 },
    { day: "Sat", display: 8.4, presence: 74 },
    { day: "Sun", display: 8.4, presence: 74 },
  ],

  "30d": Array.from({ length: 30 }, (_, i) => ({
    day: `${i + 1}`,
    display: 7.2 + Math.sin(i / 4) * 0.8,
    presence: 62 + Math.cos(i / 5) * 8,
  })),

  "90d": Array.from({ length: 12 }, (_, i) => ({
    day: `W${i + 1}`,
    display: 7.1 + Math.sin(i / 2) * 1.0,
    presence: 60 + Math.cos(i / 2.5) * 10,
  })),
};



export const trendMentions = {
  "7d": [
    { day: "Mon", mentions: 120, citations: 20 },
    { day: "Tue", mentions: 150, citations: 28 },
    { day: "Wed", mentions: 170, citations: 24 },
    { day: "Thu", mentions: 160, citations: 21 },
    { day: "Fri", mentions: 200, citations: 32 },
    { day: "Sat", mentions: 230, citations: 41 },
    { day: "Sun", mentions: 217, citations: 36 },
  ],

  "30d": Array.from({ length: 30 }, (_, i) => ({
    day: `${i + 1}`,
    mentions: 130 + Math.round(Math.sin(i / 3) * 60 + i * 2),
    citations: 20 + Math.round(Math.cos(i / 4) * 10 + i / 2),
  })),

  "90d": Array.from({ length: 12 }, (_, i) => ({
    day: `W${i + 1}`,
    mentions: 900 + Math.round(Math.sin(i / 2) * 250 + i * 40),
    citations: 120 + Math.round(Math.cos(i / 3) * 50 + i * 10),
  })),
};


export const donutData = [
  { name: "Severe", value: 2 },
  { name: "Warning", value: 5 },
  { name: "Stable", value: 12 },
];


export const pendingTasks = [
  {
    title: "Videos pending review",
    value: 6,
    icon: PlayCircle,
    href: "/admin/videos/review",
    tone: "warning",
  },
  {
    title: "Violation reports",
    value: 3,
    icon: ShieldAlert,
    href: "/admin/users/violations",
    tone: "danger",
  },
  {
    title: "AIM lessons requiring review",
    value: 4,
    icon: ClipboardList,
    href: "/admin/learning/units",
    tone: "danger",
  },
  {
    title: "Flagged battles",
    value: 2,
    icon: AlertTriangle,
    href: "/admin/battles/flags",
    tone: "info",
  },
];



export const topLessons = [
  { name: "Unit 12 – Travel", completion: 91, ctr: 18.2 },
  { name: "Unit 08 – Food", completion: 88, ctr: 16.9 },
  { name: "Unit 15 – Work", completion: 84, ctr: 15.4 },
  { name: "Unit 03 – Daily life", completion: 82, ctr: 14.1 },
  { name: "Unit 19 – Sports", completion: 79, ctr: 13.5 },
];



export const needsAttention = [
  { name: "Unit 05 – Grammar A", completion: 42, reports: 7 },
  { name: "Unit 14 – Listening", completion: 48, reports: 5 },
  { name: "Unit 21 – Speaking", completion: 51, reports: 4 },
];



export const realtimeFeed = [
  { time: "2 minutes ago", text: "Creator Linh uploaded a new video." },
  { time: "9 minutes ago", text: "Clan 'Sakura' reached level 12." },
  { time: "18 minutes ago", text: "Battle #2013 has ended (PvP)." },
  { time: "35 minutes ago", text: "Unit 12 was published successfully." },
];
