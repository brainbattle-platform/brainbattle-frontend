import type { CreatorRow } from "@/types/creators.types";

export function CreatorsStats({ creators }: { creators: CreatorRow[] }) {
  const total = creators.length;
  const active = creators.filter(c => c.status === "active").length;
  const pending = creators.filter(c => c.status === "pending").length;
  const verified = creators.filter(c => c.accessLevel !== "basic").length;
  const revenue = creators.reduce((s, c) => s + c.totalRevenueUsd, 0);

  const Card = ({ label, value, tone }: any) => (
    <div className="rounded-2xl border border-gray-200 bg-white p-4 shadow-sm">
      <div className="text-xs text-gray-500">{label}</div>
      <div className={`mt-1 text-2xl font-semibold ${tone}`}>{value}</div>
    </div>
  );

  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
      <Card label="Total creators" value={total} tone="text-gray-900" />
      <Card label="Active" value={active} tone="text-emerald-700" />
      <Card label="Pending review" value={pending} tone="text-amber-700" />
      <Card label="Verified / Partner" value={verified} tone="text-pink-700" />
      <Card
        label="Total revenue"
        value={`$${revenue.toLocaleString()}`}
        tone="text-purple-700"
      />
    </div>
  );
}
