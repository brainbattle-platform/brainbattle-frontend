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

const mockRevenue = [
  { date: "Jan 18", revenue: 820 },
  { date: "Jan 19", revenue: 1010 },
  { date: "Jan 20", revenue: 1490 },
  { date: "Jan 21", revenue: 1640 },
  { date: "Jan 22", revenue: 1380 },
  { date: "Jan 23", revenue: 1900 },
  { date: "Jan 24", revenue: 2210 },
];

export function CreatorRevenueTrendCard({
  data = mockRevenue,
}: {
  data?: { date: string; revenue: number }[];
}) {
  return (
    <div className="rounded-2xl bg-white border border-gray-200 shadow-sm p-4">
      <div className="mb-3">
        <h3 className="text-sm font-semibold text-gray-900">Creator revenue</h3>
        <p className="text-xs text-gray-500">Revenue trend (USD)</p>
      </div>

      <div className="h-56">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ left: -10, right: 8, top: 8 }}>
            <defs>
              <linearGradient id="revFill" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#a855f7" stopOpacity={0.35} />
                <stop offset="100%" stopColor="#ec4899" stopOpacity={0.05} />
              </linearGradient>
            </defs>

            <CartesianGrid strokeDasharray="3 3" vertical={false} />
            <XAxis dataKey="date" tickLine={false} axisLine={false} fontSize={12}/>
            <YAxis tickLine={false} axisLine={false} fontSize={12}/>
            <Tooltip
              contentStyle={{
                borderRadius: 12,
                border: "1px solid #eee",
                fontSize: 12,
              }}
            />

            <Area
              type="monotone"
              dataKey="revenue"
              stroke="#a855f7"
              strokeWidth={2}
              fill="url(#revFill)"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
