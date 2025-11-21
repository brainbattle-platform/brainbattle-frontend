"use client";

import { AlertTriangle } from "lucide-react";

type AttentionItem = {
  name: string;
  completion: number; // %
  reports: number;
};

export default function NeedsAttention({ data }: { data: AttentionItem[] }) {
  const getTone = (item: AttentionItem) => {
    if (item.completion < 50 || item.reports >= 6) return "danger";
    if (item.completion < 70 || item.reports >= 3) return "warning";
    return "info";
  };

  const TONES = {
    info: {
      rowBg: "bg-indigo-50/60",
      text: "text-indigo-800",
      badge: "bg-indigo-100 text-indigo-800",
      pill: "text-indigo-700",
    },
    warning: {
      rowBg: "bg-amber-50/70",
      text: "text-amber-900",
      badge: "bg-amber-100 text-amber-800",
      pill: "text-amber-700",
    },
    danger: {
      rowBg: "bg-rose-50/70",
      text: "text-rose-900",
      badge: "bg-rose-100 text-rose-800",
      pill: "text-rose-700",
    },
  } as const;

  return (
    <div
      className="
        rounded-2xl bg-white p-6
        border border-black/5
        shadow-sm hover:shadow-md transition-all
        h-full
      "
    >
      {/* Header */}
      <div className="mb-4 flex items-center gap-2">
        <div className="w-9 h-9 rounded-lg bg-gray-100 flex items-center justify-center text-gray-700">
          <AlertTriangle className="w-5 h-5" />
        </div>
        <div>
          <h2 className="text-[18px] font-semibold text-gray-900 tracking-tight">
            Needs Attention
          </h2>
          <p className="text-sm text-gray-500">
            Low completion or high report volume
          </p>
        </div>
      </div>

      {/* List */}
      <div className="space-y-3">
        {data.map((item, i) => {
          const toneKey = getTone(item);
          const tone = TONES[toneKey];

          return (
            <div
              key={i}
              className={`
                flex items-center justify-between
                rounded-xl px-3 py-3
                border border-black/5
                transition hover:bg-gray-50
                ${tone.rowBg}
              `}
            >
              {/* Left */}
              <div className="min-w-0">
                <p className={`text-sm font-semibold ${tone.text} truncate`}>
                  {item.name}
                </p>
                <p className="text-xs text-gray-500">
                  User feedback indicates issues
                </p>
              </div>

              {/* Right */}
              <div className="flex items-center gap-2 shrink-0">
                <span
                  className={`
                    text-xs font-semibold px-2.5 py-1 rounded-full
                    bg-white/70 border border-black/5
                    ${tone.pill}
                  `}
                >
                  {item.completion}% completion
                </span>

                <span
                  className={`
                    text-xs font-semibold px-2.5 py-1 rounded-full
                    border border-black/5 shadow-sm
                    ${tone.badge}
                  `}
                >
                  {item.reports} reports
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
