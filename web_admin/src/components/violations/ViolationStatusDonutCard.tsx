"use client";

import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
} from "recharts";
import type { ViolationRow } from "@/types/violations.types";

const COLORS = {
  pending: "#f59e0b",
  reviewing: "#60a5fa",
  resolved: "#10b981",
  rejected: "#94a3b8",
};

export function ViolationStatusDonutCard({
  items,
  className = "",
}: {
  items: ViolationRow[];
  className?: string;
}) {
  const pending = items.filter((i) => i.status === "pending").length;
  const reviewing = items.filter((i) => i.status === "reviewing").length;
  const resolved = items.filter((i) => i.status === "resolved").length;
  const rejected = items.filter((i) => i.status === "rejected").length;

  const data = [
    { name: "Pending", value: pending, color: COLORS.pending },
    { name: "Reviewing", value: reviewing, color: COLORS.reviewing },
    { name: "Resolved", value: resolved, color: COLORS.resolved },
    { name: "Rejected", value: rejected, color: COLORS.rejected },
  ];

  const total = data.reduce((s, d) => s + d.value, 0);

  return (
    <div
      className={[
        "rounded-2xl bg-white border border-gray-200 shadow-sm p-4",
        "flex flex-col",
        className,
      ].join(" ")}
    >
      {/* Header */}
      <div className="w-full mb-2">
        <h3 className="text-sm font-semibold text-gray-900">
          Status distribution
        </h3>
        <p className="text-xs text-gray-500">Current distribution</p>
      </div>

      {/* Bigger donut, centered */}
      <div className="w-full flex-1 flex items-center justify-center min-h-[220px]">
        <ResponsiveContainer width="88%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              innerRadius={62}
              outerRadius={108}
              paddingAngle={2}
              stroke="transparent"
            >
              {data.map((entry, i) => (
                <Cell key={i} fill={entry.color} />
              ))}
            </Pie>

            <Tooltip
              contentStyle={{
                borderRadius: 12,
                border: "1px solid #eee",
                fontSize: 12,
              }}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>

      {/* Legend pinned to bottom to avoid blank space */}
      <div className="w-full mt-auto pt-2 space-y-1.5 text-sm">
        {data.map((d, i) => (
          <div key={i} className="flex items-center justify-between px-1">
            <div className="flex items-center gap-2">
              <span
                className="w-2.5 h-2.5 rounded-full"
                style={{ background: d.color }}
              />
              <span className="text-gray-700">{d.name}</span>
            </div>

            <div className="flex items-center gap-2">
              <span className="font-medium text-gray-900">{d.value}</span>
              <span className="text-xs text-gray-400">
                {total ? Math.round((d.value / total) * 100) : 0}%
              </span>
            </div>
          </div>
        ))}

        {/* subtle note at very bottom */}
        <div className="pt-1 text-[11px] text-gray-400 text-center">
          Updated from latest reports
        </div>
      </div>
    </div>
  );
}
