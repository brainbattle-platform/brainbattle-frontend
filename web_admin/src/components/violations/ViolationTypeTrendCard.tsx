"use client";

import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from "recharts";

const mockTypeTrend = [
  { date: "Jan 18", spam: 3, harassment: 1, hate: 0 },
  { date: "Jan 19", spam: 2, harassment: 2, hate: 1 },
  { date: "Jan 20", spam: 4, harassment: 1, hate: 2 },
  { date: "Jan 21", spam: 3, harassment: 3, hate: 1 },
  { date: "Jan 22", spam: 2, harassment: 2, hate: 3 },
  { date: "Jan 23", spam: 1, harassment: 2, hate: 2 },
  { date: "Jan 24", spam: 2, harassment: 1, hate: 4 },
];

export function ViolationTypeTrendCard({ className = "" }: { className?: string }) {
  return (
    <div
      className={[
        "rounded-2xl bg-white border border-gray-200 shadow-sm p-4",
        "flex flex-col",
        className,
      ].join(" ")}
    >
      <div className="mb-3">
        <h3 className="text-sm font-semibold text-gray-900">
          Report volume by type
        </h3>
        <p className="text-xs text-gray-500">Last 7 days</p>
      </div>

      {/* flex-1 to stretch same height as donut */}
      <div className="flex-1 min-h-[220px]">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={mockTypeTrend} margin={{ left: -12, right: 8 }}>
            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="date" tickLine={false} axisLine={false} fontSize={12} />
            <YAxis tickLine={false} axisLine={false} fontSize={12} />
            <Tooltip
              contentStyle={{
                borderRadius: 12,
                border: "1px solid #eee",
                fontSize: 12,
              }}
            />

            <Area
              type="monotone"
              dataKey="spam"
              stroke="#ec4899"
              fill="#ec489933"
              strokeWidth={2}
            />
            <Area
              type="monotone"
              dataKey="harassment"
              stroke="#a855f7"
              fill="#a855f733"
              strokeWidth={2}
            />
            <Area
              type="monotone"
              dataKey="hate"
              stroke="#f59e0b"
              fill="#f59e0b33"
              strokeWidth={2}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
