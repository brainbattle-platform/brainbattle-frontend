import { AccountStatus } from "@/types/learners.types";

export function StatusBadge({ status }: { status: AccountStatus }) {
  const map: Record<AccountStatus, { label: string; cls: string }> = {
    active: {
      label: "Active",
      cls: "bg-emerald-100 text-emerald-700 ring-1 ring-emerald-300",
    },
    suspended: {
      label: "Suspended",
      cls: "bg-amber-100 text-amber-700 ring-1 ring-amber-300",
    },
    deleted: {
      label: "Deleted",
      cls: "bg-rose-100 text-rose-700 ring-1 ring-rose-300",
    },
  };

  return (
    <span
      className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium ${map[status].cls}`}
    >
      {map[status].label}
    </span>
  );
}
