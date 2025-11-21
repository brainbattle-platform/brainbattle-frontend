"use client";

import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from "recharts";
import type { UserRow } from "@/types/learners.types";

const COLORS = ["#10b981", "#f59e0b", "#f43f5e"]; // active, suspended, deleted

export function LearnerStatusDonutCard({ users }: { users: UserRow[] }) {
  const active = users.filter((u) => u.status === "active").length;
  const suspended = users.filter((u) => u.status === "suspended").length;
  const deleted = users.filter((u) => u.status === "deleted").length;

  const data = [
    { name: "Active", value: active },
    { name: "Suspended", value: suspended },
    { name: "Deleted", value: deleted },
  ];

  return (
    <div className="rounded-2xl bg-white border border-gray-200 shadow-sm p-4">
      <div className="mb-3">
        <h3 className="text-sm font-semibold text-gray-900">Status distribution</h3>
        <p className="text-xs text-gray-500">Current learner statuses</p>
      </div>

      <div className="h-56 grid grid-cols-2 gap-2 items-center">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="value"
              innerRadius={48}
              outerRadius={80}
              paddingAngle={2}
            >
              {data.map((_, i) => (
                <Cell key={i} fill={COLORS[i]} />
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

        <div className="space-y-2 text-sm">
          {data.map((d, i) => (
            <div key={d.name} className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span
                  className="w-2.5 h-2.5 rounded-full"
                  style={{ background: COLORS[i] }}
                />
                <span className="text-gray-700">{d.name}</span>
              </div>
              <span className="font-medium text-gray-900">{d.value}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
