import { UserRow } from "@/types/learners.types";
import { LearnerRow } from "./LearnerRow";

export function LearnersTable({
  users,
  selectedIds,
  onToggleSelect,
  onToggleAll,
}: {
  users: UserRow[];
  selectedIds: Set<string>;
  onToggleSelect: (id: string) => void;
  onToggleAll: (checked: boolean) => void;
}) {
  return (
    <div className="overflow-x-auto rounded-2xl bg-white border border-gray-200 shadow-sm">
      <table className="min-w-full">
        <thead>
          <tr className="text-left text-gray-600 text-sm border-b border-gray-200">

            {/* ==== Select All Checkbox ==== */}
            <th className="px-3 py-3 w-10">
              <input
                type="checkbox"
                checked={
                  users.length > 0 &&
                  users.every((u) => selectedIds.has(u.id))
                }
                ref={(el) => {
                  if (!el) return;
                  const all = users.length > 0 &&
                    users.every((u) => selectedIds.has(u.id));
                  const some = users.some((u) => selectedIds.has(u.id));

                  el.indeterminate = !all && some;
                }}
                onChange={(e) => onToggleAll(e.target.checked)}
                className="w-4 h-4 rounded border-gray-300 text-pink-600 focus:ring-pink-400/40"
              />
            </th>

            <th className="px-5 py-3 font-medium">User</th>
            <th className="px-5 py-3 font-medium">User ID (UUID)</th>
            <th className="px-5 py-3 font-medium">Status</th>
            <th className="px-5 py-3 font-medium">Created at</th>
            <th className="px-5 py-3 font-medium">Last login</th>
            <th className="px-5 py-3 font-medium">Last device</th>
            <th className="px-5 py-3 font-medium text-center">Actions</th>
          </tr>
        </thead>

        <tbody className="text-sm">
          {users.map((u) => (
            <LearnerRow
              key={u.id}
              u={u}
              checked={selectedIds.has(u.id)}
              onToggle={() => onToggleSelect(u.id)}
            />
          ))}

          {users.length === 0 && (
            <tr>
              <td colSpan={8} className="px-5 py-10 text-center text-gray-500">
                No learners match your search.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
