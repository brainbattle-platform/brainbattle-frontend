"use client";

import {
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Tooltip,
} from "recharts";

type DonutItem = {
  name: string;
  value: number;
};

interface Props {
  data: DonutItem[];
  title?: string;
  subtitle?: string;
}

const COLORS = [
  "#6366F1", 
  "#F59E0B", 
  "#10B981", 
];

function SaaSTooltip({
  active,
  payload,
}: {
  active?: boolean;
  payload?: any[];
}) {
  if (!active || !payload?.length) return null;

  const d = payload[0];

  return (
    <div className="rounded-lg border border-black/10 bg-white px-3 py-2 shadow-sm">
      <div className="text-xs font-medium text-gray-500">{d.name}</div>
      <div className="mt-0.5 text-sm font-semibold text-gray-900">
        {d.value}
      </div>
    </div>
  );
}

export default function DonutChartCard({
  data,
  title = "Optimization Status",
  subtitle = "LLM visibility health breakdown",
}: Props) {
  const total = data.reduce((s, x) => s + x.value, 0);

  return (
    <div
      className="
        rounded-2xl bg-white p-6
        border border-black/5
        shadow-sm hover:shadow-md transition-all
        h-full
      "
    >
      <div>
        <h2 className="text-[18px] font-semibold text-gray-900 tracking-tight">
          {title}
        </h2>
        {subtitle && (
          <p className="text-sm text-gray-500 mt-1">{subtitle}</p>
        )}
      </div>

      <div className="mt-5 grid grid-cols-1 md:grid-cols-2 gap-6 items-center">
        <div className="relative h-[220px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={data}
                dataKey="value"
                nameKey="name"
                innerRadius={70}
                outerRadius={95}
                paddingAngle={2}
                stroke="white"
                strokeWidth={2}
              >
                {data.map((_, i) => (
                  <Cell key={i} fill={COLORS[i % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip content={<SaaSTooltip />} />
            </PieChart>
          </ResponsiveContainer>

          <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
            <div className="text-[24px] font-semibold text-gray-900">
              {total}
            </div>
            <div className="text-xs font-medium text-gray-500 mt-0.5">
              Total items
            </div>
          </div>
        </div>

        <div className="space-y-3">
          {data.map((item, i) => {
            const pct = total > 0 ? Math.round((item.value / total) * 100) : 0;

            return (
              <div
                key={item.name}
                className="flex items-center justify-between rounded-lg px-2 py-2 hover:bg-gray-50 transition"
              >
                <div className="flex items-center gap-2">
                  <span
                    className="w-2.5 h-2.5 rounded-full"
                    style={{ background: COLORS[i % COLORS.length] }}
                  />
                  <span className="text-sm font-medium text-gray-700">
                    {item.name}
                  </span>
                </div>

                <div className="text-sm text-gray-900 font-semibold">
                  {item.value}{" "}
                  <span className="text-gray-400 font-medium">({pct}%)</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
