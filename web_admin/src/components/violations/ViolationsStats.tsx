import type { ViolationRow } from "@/types/violations.types";

export function ViolationsStats({ items }: { items: ViolationRow[] }) {
  const total = items.length;
  const pending = items.filter(i => i.status === "pending").length;
  const reviewing = items.filter(i => i.status === "reviewing").length;
  const resolved = items.filter(i => i.status === "resolved").length;
  const critical = items.filter(i => i.severity === "critical").length;

  const cards = [
    { label: "Total reports", value: total },
    { label: "Pending", value: pending, tone: "text-amber-700" },
    { label: "Reviewing", value: reviewing, tone: "text-blue-700" },
    { label: "Resolved", value: resolved, tone: "text-emerald-700" },
    { label: "Critical", value: critical, tone: "text-rose-700" },
  ];

  return (
    <div className="grid grid-cols-1 md:grid-cols-5 gap-3">
      {cards.map(c => (
        <div
          key={c.label}
          className="rounded-2xl bg-white border border-gray-200 shadow-sm p-4"
        >
          <div className="text-xs text-gray-500">{c.label}</div>
          <div className={`text-2xl font-semibold ${c.tone ?? "text-gray-900"}`}>
            {c.value}
          </div>
        </div>
      ))}
    </div>
  );
}
