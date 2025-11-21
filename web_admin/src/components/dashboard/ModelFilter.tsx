"use client";

export type ModelKey = "all" | "gpt" | "claude" | "llama";

interface ModelFilterProps {
  value: ModelKey;
  onChange: (v: ModelKey) => void;
}

const models = [
  { label: "All Models", value: "all" },
  { label: "GPT", value: "gpt" },
  { label: "Claude", value: "claude" },
  { label: "LLaMA", value: "llama" },
] as const;

export default function ModelFilter({ value, onChange }: ModelFilterProps) {
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
      {models.map((m) => {
        const active = value === m.value;

        return (
          <button
            key={m.value}
            onClick={() => onChange(m.value)}
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
            {m.label}
          </button>
        );
      })}
    </div>
  );
}
