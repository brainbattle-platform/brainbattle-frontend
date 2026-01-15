"use client";

import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid } from "recharts";

type TabKey = "attempts" | "completions" | "brand" | "mentions";

type BrandPoint = {
  day: string;
  display: number;
  presence: number;
};

type MentionPoint = {
  day: string;
  mentions: number;
  citations: number;
};

type LearningPoint = {
  day: string;
  attempts: number;
  completions: number;
};

interface Props {
  title: string;
  subtitle?: string;
  data: Array<BrandPoint | MentionPoint | LearningPoint>;
  tab: TabKey;
  onTabChange: (t: TabKey) => void;
}

function SaaSTooltip({
  active,
  payload,
  label,
}: {
  active?: boolean;
  payload?: any[];
  label?: string;
}) {
  if (!active || !payload?.length) return null;

  return (
    <div className="rounded-lg border border-black/10 bg-white px-3 py-2 shadow-sm">
      <div className="text-xs font-medium text-gray-500">{label}</div>
      <div className="mt-1 space-y-0.5">
        {payload.map((p, i) => (
          <div key={i} className="flex items-center justify-between gap-6 text-sm">
            <span className="text-gray-700">{p.name}</span>
            <span className="font-semibold text-gray-900">
              {typeof p.value === "number" ? p.value.toFixed(2) : p.value}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function TrendChartCard({
  title,
  subtitle,
  data,
  tab,
  onTabChange,
}: Props) {
  const isBrand = tab === "brand";
  const isMentions = tab === "mentions";
  const isAttempts = tab === "attempts";
  const isCompletions = tab === "completions";
  const isLearning = isAttempts || isCompletions;

  return (
    <div
      className="
        col-span-1 lg:col-span-2
        rounded-2xl bg-white p-6
        border border-black/5
        shadow-sm hover:shadow-md transition-all
      "
    >
      <div className="flex items-start justify-between gap-4">
        <div>
          <h2 className="text-[18px] font-semibold text-gray-900 tracking-tight">
            {title}
          </h2>
          {subtitle && (
            <p className="text-sm text-gray-500 mt-1">{subtitle}</p>
          )}
        </div>

        <div className="flex items-center gap-4 text-sm">
          {isLearning ? (
            <>
              <button
                onClick={() => onTabChange("attempts")}
                className={
                  isAttempts
                    ? "font-semibold text-gray-900 border-b-2 border-gray-900 pb-1"
                    : "text-gray-500 hover:text-gray-700 pb-1"
                }
              >
                Attempts
              </button>
              <button
                onClick={() => onTabChange("completions")}
                className={
                  isCompletions
                    ? "font-semibold text-gray-900 border-b-2 border-gray-900 pb-1"
                    : "text-gray-500 hover:text-gray-700 pb-1"
                }
              >
                Completions
              </button>
            </>
          ) : (
            <>
              <button
                onClick={() => onTabChange("brand")}
                className={
                  isBrand
                    ? "font-semibold text-gray-900 border-b-2 border-gray-900 pb-1"
                    : "text-gray-500 hover:text-gray-700 pb-1"
                }
              >
                Visibility & Presence
              </button>
              <button
                onClick={() => onTabChange("mentions")}
                className={
                  isMentions
                    ? "font-semibold text-gray-900 border-b-2 border-gray-900 pb-1"
                    : "text-gray-500 hover:text-gray-700 pb-1"
                }
              >
                Mentions & Citations
              </button>
            </>
          )}
        </div>
      </div>

      <div className="mt-5 h-[320px] w-full">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data} margin={{ top: 8, right: 16, left: 0, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />

            <XAxis
              dataKey="day"
              tick={{ fontSize: 12, fill: "#6B7280" }}
              axisLine={{ stroke: "rgba(0,0,0,0.08)" }}
              tickLine={false}
            />

            <YAxis
              yAxisId="left"
              tick={{ fontSize: 12, fill: "#6B7280" }}
              axisLine={false}
              tickLine={false}
              domain={["auto", "auto"]}
              width={36}
            />

            <YAxis
              yAxisId="right"
              orientation="right"
              tick={{ fontSize: 12, fill: "#6B7280" }}
              axisLine={false}
              tickLine={false}
              domain={["auto", "auto"]}
              width={36}
            />

            <Tooltip content={<SaaSTooltip />} />

            {isLearning ? (
              <>
                <Line
                  yAxisId="left"
                  type="monotone"
                  dataKey="attempts"
                  name="Attempts"
                  stroke="#ff5d82"
                  strokeWidth={2.5}
                  dot={false}
                  activeDot={{ r: 4 }}
                />

                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="completions"
                  name="Completions"
                  stroke="#a855f7"
                  strokeWidth={2.5}
                  dot={false}
                  activeDot={{ r: 4 }}
                />
              </>
            ) : isBrand ? (
              <>
                <Line
                  yAxisId="left"
                  type="monotone"
                  dataKey="display"
                  name="Visibility Score"
                  stroke="#ff5d82"
                  strokeWidth={2.5}
                  dot={false}
                  activeDot={{ r: 4 }}
                />

                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="presence"
                  name="Presence Score"
                  stroke="#a855f7"
                  strokeWidth={2.5}
                  dot={false}
                  activeDot={{ r: 4 }}
                />
              </>
            ) : (
              <>
                <Line
                  yAxisId="left"
                  type="monotone"
                  dataKey="mentions"
                  name="Mentions"
                  stroke="#ff5d82"
                  strokeWidth={2.5}
                  dot={false}
                  activeDot={{ r: 4 }}
                />

                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="citations"
                  name="Citations"
                  stroke="#a855f7"
                  strokeWidth={2.5}
                  dot={false}
                  activeDot={{ r: 4 }}
                />
              </>
            )}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
