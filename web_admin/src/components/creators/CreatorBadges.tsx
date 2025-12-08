import type { CreatorStatus, AccessLevel } from "@/types/creators.types";

export function CreatorStatusBadge({ status }: { status: CreatorStatus }) {
  const map: Record<CreatorStatus, { label: string; cls: string }> = {
    active: { label: "Active", cls: "bg-emerald-100 text-emerald-700 ring-1 ring-emerald-300" },
    pending: { label: "Pending", cls: "bg-amber-100 text-amber-700 ring-1 ring-amber-300" },
    suspended: { label: "Suspended", cls: "bg-rose-100 text-rose-700 ring-1 ring-rose-300" },
    deleted: { label: "Deleted", cls: "bg-gray-100 text-gray-600 ring-1 ring-gray-200" },
  };
  return <span className={`px-2.5 py-1 rounded-full text-xs font-medium inline-flex ${map[status].cls}`}>{map[status].label}</span>;
}

export function AccessLevelBadge({ level }: { level: AccessLevel }) {
  const map: Record<AccessLevel, { label: string; cls: string }> = {
    basic: { label: "Basic", cls: "bg-gray-100 text-gray-700 ring-1 ring-gray-200" },
    verified: { label: "Verified", cls: "bg-pink-100 text-pink-700 ring-1 ring-pink-200" },
    partner: { label: "Partner", cls: "bg-purple-100 text-purple-700 ring-1 ring-purple-200" },
  };
  return <span className={`px-2.5 py-1 rounded-full text-xs font-medium inline-flex ${map[level].cls}`}>{map[level].label}</span>;
}
