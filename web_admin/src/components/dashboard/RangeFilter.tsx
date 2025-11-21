"use client";

export type RangeKey = "7d" | "30d" | "90d";

interface RangeFilterProps {
  value: RangeKey;
  onChange: (v: RangeKey) => void;
}

const ranges = [
  { label: "7 days", value: "7d" },
  { label: "30 days", value: "30d" },
  { label: "90 days", value: "90d" },
] as const;

export default function RangeFilter({ value, onChange }: RangeFilterProps) {
  return (
    <div
      className="
        inline-flex items-center 
        rounded-xl 
        border border-black/10 
        bg-gray-50
        p-1
      "
    >
      {ranges.map((r) => {
        const active = value === r.value;

        return (
          <button
            key={r.value}
            onClick={() => onChange(r.value)}
            className={`
              px-4 py-1.5
              rounded-lg
              text-sm font-medium
              transition-all
              ${
                active
                  ? "bg-white shadow-sm text-gray-900"
                  : "text-gray-500 hover:text-gray-700"
              }
            `}
          >
            {r.label}
          </button>
        );
      })}
    </div>
  );
}
