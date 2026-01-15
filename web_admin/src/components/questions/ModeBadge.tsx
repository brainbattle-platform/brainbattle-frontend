const MODE_COLORS: Record<string, { bg: string; text: string; border: string }> = {
  listening: { bg: "bg-blue-50", text: "text-blue-700", border: "border-blue-200" },
  speaking: { bg: "bg-purple-50", text: "text-purple-700", border: "border-purple-200" },
  reading: { bg: "bg-green-50", text: "text-green-700", border: "border-green-200" },
  writing: { bg: "bg-orange-50", text: "text-orange-700", border: "border-orange-200" },
};

export function ModeBadge({ mode }: { mode: string }) {
  const colors = MODE_COLORS[mode] || { bg: "bg-gray-50", text: "text-gray-700", border: "border-gray-200" };
  const label = mode.charAt(0).toUpperCase() + mode.slice(1);

  return (
    <span
      className={[
        "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium border",
        colors.bg,
        colors.text,
        colors.border,
      ].join(" ")}
    >
      {label}
    </span>
  );
}

