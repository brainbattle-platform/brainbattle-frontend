"use client";

import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from "recharts";
import type { CreatorRow } from "@/types/creators.types";

const COLORS = ["#10b981", "#f59e0b", "#f43f5e", "#94a3b8"];

export function CreatorStatusDonutCard({ creators }: { creators: CreatorRow[] }) {
  const active = creators.filter((c) => c.status === "active").length;
  const pending = creators.filter((c) => c.status === "pending").length;
  const suspended = creators.filter((c) => c.status === "suspended").length;
  const deleted = creators.filter((c) => c.status === "deleted").length;

  const data = [
    { name: "Active", value: active, color: COLORS[0] },
    { name: "Pending", value: pending, color: COLORS[1] },
    { name: "Suspended", value: suspended, color: COLORS[2] },
    { name: "Deleted", value: deleted, color: COLORS[3] },
  ];

  return (
    <div className="rounded-2xl bg-white border border-gray-200 shadow-sm p-4 flex flex-col">
      {/* Header (giữ nguyên) */}
      <div className="mb-2">
        <h3 className="text-sm font-semibold text-gray-900">Creator statuses</h3>
      </div>

      {/* Donut */}
      <div className="w-full flex items-center justify-center h-60">
        <ResponsiveContainer width="88%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              innerRadius={58}
              outerRadius={98}
              paddingAngle={2}
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

      {/* Legend */}
      <div className="mt-3 space-y-1.5 text-sm">
        {data.map((d, i) => (
          <div key={i} className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span
                className="w-2.5 h-2.5 rounded-full"
                style={{ background: d.color }}
              />
              <span className="text-gray-700">{d.name}</span>
            </div>
            <span className="font-medium text-gray-900">{d.value}</span>
          </div>
        ))}
      </div>

      <div className="pt-2 mt-auto text-xs text-gray-500 text-center">
        Current distribution
      </div>
    </div>
  );
}
