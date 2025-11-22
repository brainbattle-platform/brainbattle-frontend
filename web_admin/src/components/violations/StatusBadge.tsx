const STATUS_COLORS: Record<string, string> = {
  pending: "bg-amber-50 text-amber-700 border-amber-200",
  reviewing: "bg-blue-50 text-blue-700 border-blue-200",
  resolved: "bg-emerald-50 text-emerald-700 border-emerald-200",
  rejected: "bg-gray-100 text-gray-700 border-gray-300",
};

export function StatusBadge({ status }: { status: string }) {
  const cls = STATUS_COLORS[status] ?? STATUS_COLORS.pending;

  return (
    <span
      className={`
        inline-flex items-center px-2.5 py-1
        text-xs font-semibold capitalize
        border rounded-full
        ${cls}
      `}
    >
      {status}
    </span>
  );
}
