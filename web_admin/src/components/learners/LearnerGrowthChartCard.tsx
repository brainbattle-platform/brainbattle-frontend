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

const mockGrowth = [
  { date: "Jan 18", learners: 12 },
  { date: "Jan 19", learners: 18 },
  { date: "Jan 20", learners: 25 },
  { date: "Jan 21", learners: 30 },
  { date: "Jan 22", learners: 28 },
  { date: "Jan 23", learners: 36 },
  { date: "Jan 24", learners: 44 },
];

export function LearnerGrowthChartCard({
  data = mockGrowth,
  title = "Learner growth",
  subtitle = "New learners over time",
}: {
  data?: { date: string; learners: number }[];
  title?: string;
  subtitle?: string;
}) {
  return (
    <div className="rounded-2xl bg-white border border-gray-200 shadow-sm p-4">
      <div className="mb-3">
        <h3 className="text-sm font-semibold text-gray-900">{title}</h3>
        <p className="text-xs text-gray-500">{subtitle}</p>
      </div>

      <div className="h-56">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data} margin={{ left: -10, right: 8, top: 8 }}>
            <defs>
              <linearGradient id="learnersFill" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#ec4899" stopOpacity={0.35} />
                <stop offset="100%" stopColor="#a855f7" stopOpacity={0.05} />
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
              dataKey="learners"
              stroke="#ec4899"
              strokeWidth={2}
              fill="url(#learnersFill)"
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
