import type { CreatorRow as CreatorRowType } from "@/types/creators.types";
import { CreatorRow } from "./CreatorRow";

export function CreatorsTable({
  creators,
  selectedIds,
  onToggleSelect,
  onToggleAll,
}: {
  creators: CreatorRowType[];
  selectedIds: Set<string>;
  onToggleSelect: (id: string) => void;
  onToggleAll: (checked: boolean) => void;
}) {
  const allSelected = creators.length > 0 && creators.every(c => selectedIds.has(c.id));
  const someSelected = creators.some(c => selectedIds.has(c.id));

  return (
    <div className="overflow-x-auto rounded-2xl bg-white border border-gray-200 shadow-sm">
      <table className="min-w-full">
        <thead>
          <tr className="text-left text-gray-600 text-sm border-b border-gray-200">
            <th className="px-3 py-3 w-10">
              <input
                type="checkbox"
                checked={allSelected}
                ref={(el) => { if (el) el.indeterminate = !allSelected && someSelected; }}
                onChange={(e) => onToggleAll(e.target.checked)}
                className="w-4 h-4 rounded border-gray-300 text-pink-600 focus:ring-pink-400/40"
              />
            </th>

            <th className="px-5 py-3 font-medium">Creator</th>
            <th className="px-5 py-3 font-medium">Creator ID (UUID)</th>
            <th className="px-5 py-3 font-medium">Status & Access</th>
            <th className="px-5 py-3 font-medium">Courses</th>
            <th className="px-5 py-3 font-medium">Students</th>
            <th className="px-5 py-3 font-medium">Rating</th>
            <th className="px-5 py-3 font-medium">Revenue</th>
            <th className="px-5 py-3 font-medium">Created at</th>
            <th className="px-5 py-3 font-medium">Last active</th>
            <th className="px-5 py-3 font-medium">Last device</th>
            <th className="px-5 py-3 font-medium text-center">Actions</th>
          </tr>
        </thead>

        <tbody className="text-sm">
          {creators.map(c => (
            <CreatorRow
              key={c.id}
              c={c}
              selected={selectedIds.has(c.id)}
              onToggleSelect={onToggleSelect}
            />
          ))}

          {creators.length === 0 && (
            <tr>
              <td colSpan={12} className="px-5 py-10 text-center text-gray-500">
                No creators match your search.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
