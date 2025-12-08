import { UserRow } from "@/types/learners.types";

export function LearnersStats({ users }: { users: UserRow[] }) {
  const total = users.length;
  const active = users.filter((u) => u.status === "active").length;
  const suspended = users.filter((u) => u.status === "suspended").length;
  const deleted = users.filter((u) => u.status === "deleted").length;

  const Item = ({ label, value, tone }: any) => (
    <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm">
      <div className="text-xs text-gray-500">{label}</div>
      <div className={`mt-1 text-2xl font-semibold ${tone}`}>{value}</div>
    </div>
  );

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
      <Item label="Total learners" value={total} tone="text-gray-900" />
      <Item label="Active" value={active} tone="text-emerald-700" />
      <Item label="Suspended" value={suspended} tone="text-amber-700" />
      <Item label="Deleted" value={deleted} tone="text-rose-700" />
    </div>
  );
}
