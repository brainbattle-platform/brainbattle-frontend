"use client";

type FeedItem = {
  time: string;
  text: string;
};

interface RealtimeFeedProps {
  data: FeedItem[];
  title?: string;
  subtitle?: string;
}

export default function RealtimeFeed({
  data,
  title = "Realtime Activity",
  subtitle = "Latest system events and user actions",
}: RealtimeFeedProps) {
  return (
    <div
      className="
        rounded-2xl bg-white p-6
        border border-black/5
        shadow-sm hover:shadow-md transition-all
      "
    >
      <div className="mb-4">
        <h2 className="text-[18px] font-semibold text-gray-900 tracking-tight">
          {title}
        </h2>
        {subtitle && (
          <p className="text-sm text-gray-500 mt-1">{subtitle}</p>
        )}
      </div>

      <div className="relative pl-4 border-l border-gray-200 space-y-4">
        {data.map((item, i) => (
          <div key={i} className="relative">
            <span
              className="
                absolute -left-[9px] top-1.5
                w-2.5 h-2.5 rounded-full
                bg-gray-900
              "
            />

            <div className="rounded-xl px-3 py-2.5 hover:bg-gray-50 transition">
              <p className="text-sm font-medium text-gray-900 leading-relaxed">
                {item.text}
              </p>
              <p className="text-xs text-gray-500 mt-1">{item.time}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
