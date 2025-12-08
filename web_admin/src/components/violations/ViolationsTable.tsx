import type { ViolationRow } from "@/types/violations.types";
import { ViolationRowItem } from "./ViolationRow";
import { ArrowUpDown } from "lucide-react";

export function ViolationsTable({
  items,
  selectedIds,
  onToggleSelect,
  onToggleAll,
}: {
  items: ViolationRow[];
  selectedIds: Set<string>;
  onToggleSelect: (id: string) => void;
  onToggleAll: (checked: boolean) => void;
}) {
  const allVisibleSelected =
    items.length > 0 && items.every((i) => selectedIds.has(i.id));

  return (
    <div className="overflow-x-auto rounded-2xl bg-white border border-gray-200 shadow-sm">
      <table className="min-w-full">
        <thead className="bg-white sticky top-0 z-10">
          <tr className="text-left text-gray-500 text-sm border-b border-gray-100">
            {/* checkbox head */}
            <th className="pl-4 pr-2 py-3 w-10">
              <input
                type="checkbox"
                checked={allVisibleSelected}
                onChange={(e) => onToggleAll(e.target.checked)}
                className="w-4 h-4 rounded border-gray-300 text-pink-600 focus:ring-pink-400/40"
                aria-label="Select all"
              />
            </th>

            <Th label="Report" />
            <Th label="Type" sortable />
            <Th label="Severity" sortable />
            <Th label="Status" sortable />
            <Th label="Created at" sortable />
            <Th label="Assigned" />
            <Th label="Actions" align="center" />
          </tr>
        </thead>

        <tbody className="text-sm">
          {items.map((item) => (
            <ViolationRowItem
              key={item.id}
              item={item}
              checked={selectedIds.has(item.id)}
              onToggle={() => onToggleSelect(item.id)}
            />
          ))}

          {items.length === 0 && (
            <tr>
              <td colSpan={8} className="px-5 py-12 text-center text-gray-500">
                No reports match your filters.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

/** Creator-vibe table header cell */
function Th({
  label,
  sortable,
  align = "left",
}: {
  label: string;
  sortable?: boolean;
  align?: "left" | "center" | "right";
}) {
  return (
    <th
      className={[
        "px-5 py-3 font-medium whitespace-nowrap",
        align === "center" && "text-center",
        align === "right" && "text-right",
      ]
        .filter(Boolean)
        .join(" ")}
    >
      <div
        className={[
          "inline-flex items-center gap-1",
          sortable && "cursor-pointer hover:text-gray-700 transition",
        ]
          .filter(Boolean)
          .join(" ")}
      >
        <span>{label}</span>
        {sortable && <ArrowUpDown className="w-3.5 h-3.5 text-gray-400" />}
      </div>
    </th>
  );
}
