import { UnitRow as UnitRowType } from "@/types/units.types";
import { UnitRow } from "./UnitRow";

export function UnitsTable({
  units,
  onEdit,
  onDelete,
  onPublish,
  onUnpublish,
  onMoveUp,
  onMoveDown,
}: {
  units: UnitRowType[];
  onEdit: (unit: UnitRowType) => void;
  onDelete: (unit: UnitRowType) => void;
  onPublish: (unit: UnitRowType) => void;
  onUnpublish: (unit: UnitRowType) => void;
  onMoveUp?: (unit: UnitRowType) => void;
  onMoveDown?: (unit: UnitRowType) => void;
}) {
  return (
    <div className="overflow-x-auto rounded-2xl bg-white border border-gray-200 shadow-sm">
      <table className="min-w-full">
        <thead>
          <tr className="text-left text-gray-600 text-sm border-b border-gray-200">
            <th className="px-5 py-3 font-medium">Unit</th>
            <th className="px-5 py-3 font-medium">Status</th>
            <th className="px-5 py-3 font-medium">Lessons</th>
            <th className="px-5 py-3 font-medium">Order</th>
            <th className="px-5 py-3 font-medium">Created</th>
            <th className="px-5 py-3 font-medium text-center">Actions</th>
          </tr>
        </thead>
        <tbody>
          {units.length === 0 ? (
            <tr>
              <td colSpan={6} className="px-5 py-12 text-center text-gray-500">
                No units found
              </td>
            </tr>
          ) : (
            units.map((unit) => (
              <UnitRow
                key={unit.id}
                unit={unit}
                onEdit={() => onEdit(unit)}
                onDelete={() => onDelete(unit)}
                onPublish={() => onPublish(unit)}
                onUnpublish={() => onUnpublish(unit)}
                onMoveUp={onMoveUp ? () => onMoveUp(unit) : undefined}
                onMoveDown={onMoveDown ? () => onMoveDown(unit) : undefined}
              />
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}

