"use client";

type LessonItem = {
  name: string;
  completion: number; // %
  ctr: number; // %
};

interface TopLessonsProps {
  data: LessonItem[];
  title?: string;
  subtitle?: string;
}

export default function TopLessons({
  data,
  title = "Top Performing Lessons",
  subtitle = "Highest completion and engagement rates",
}: TopLessonsProps) {
  const sorted = [...data].sort((a, b) => b.completion - a.completion);

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
      <div className="mb-4">
        <h2 className="text-[18px] font-semibold text-gray-900 tracking-tight">
          {title}
        </h2>
        {subtitle && (
          <p className="text-sm text-gray-500 mt-1">{subtitle}</p>
        )}
      </div>

      {/* List */}
      <div className="space-y-3">
        {sorted.map((item, i) => (
          <div
            key={i}
            className="
              rounded-xl px-3 py-3
              border border-black/5
              hover:bg-gray-50 transition
            "
          >
            <div className="flex items-start justify-between gap-3">
              {/* Name */}
              <div className="min-w-0">
                <p className="text-sm font-semibold text-gray-900 truncate">
                  {item.name}
                </p>
                <p className="text-xs text-gray-500 mt-0.5">
                  Completion & CTR performance
                </p>
              </div>

              {/* CTR badge */}
              <div className="shrink-0">
                <span
                  className="
                    text-xs font-semibold
                    bg-indigo-50 text-indigo-700
                    border border-indigo-100
                    px-2.5 py-1 rounded-full
                  "
                >
                  {item.ctr}% CTR
                </span>
              </div>
            </div>

            {/* Completion bar */}
            <div className="mt-3 flex items-center gap-3">
              <div className="flex-1 h-2 rounded-full bg-gray-100 overflow-hidden">
                <div
                  className="h-full bg-gray-900 rounded-full"
                  style={{ width: `${item.completion}%` }}
                />
              </div>

              <span className="text-xs font-semibold text-gray-700 w-14 text-right">
                {item.completion}%
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
