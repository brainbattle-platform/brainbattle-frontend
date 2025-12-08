const COLORS: Record<string, string> = {
  critical: "bg-red-100 text-red-600 border-red-200",
  high: "bg-red-50 text-red-600 border-red-200",
  medium: "bg-amber-50 text-amber-700 border-amber-200",
  low: "bg-gray-100 text-gray-700 border-gray-300",
};

export function SeverityBadge({ severity }: { severity: string }) {
  const cls = COLORS[severity] ?? COLORS.low;

  return (
    <span
      className={`
        inline-flex items-center px-2.5 py-1
        text-xs font-semibold capitalize
        border rounded-full
        ${cls}
      `}
    >
      {severity}
    </span>
  );
}
