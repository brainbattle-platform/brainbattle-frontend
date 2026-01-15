import { UnitRow as UnitRowType } from "@/types/units.types";
import { PublishedBadge } from "./PublishedBadge";
import { UnitActionMenu } from "./UnitActionMenu";

const fmtDate = (iso?: string) => {
  if (!iso) return "—";
  const d = new Date(iso);
  return d.toLocaleDateString("en-US", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
};

export function UnitRow({
  unit,
  onEdit,
  onDelete,
  onPublish,
  onUnpublish,
  onMoveUp,
  onMoveDown,
}: {
  unit: UnitRowType;
  onEdit: () => void;
  onDelete: () => void;
  onPublish: () => void;
  onUnpublish: () => void;
  onMoveUp?: () => void;
  onMoveDown?: () => void;
}) {
  return (
    <tr className="border-b border-gray-100 hover:bg-gray-50 transition">
      <td className="px-5 py-4">
        <div className="flex flex-col gap-1">
          <span className="font-semibold text-gray-900">{unit.title}</span>
          <span className="text-xs text-gray-500">{unit.unitId}</span>
        </div>
      </td>
      <td className="px-5 py-4">
        <PublishedBadge published={unit.published} />
      </td>
      <td className="px-5 py-4 text-sm text-gray-600">
        {unit.lessonsCount ?? unit.lessons?.length ?? 0} lessons
      </td>
      <td className="px-5 py-4 text-sm text-gray-600">
        Order: {unit.order}
      </td>
      <td className="px-5 py-4 text-sm text-gray-500">
        {fmtDate(unit.createdAt)}
      </td>
      <td className="px-5 py-4 text-center">
        <UnitActionMenu
          unit={unit}
          onEdit={onEdit}
          onDelete={onDelete}
          onPublish={onPublish}
          onUnpublish={onUnpublish}
          onMoveUp={onMoveUp}
          onMoveDown={onMoveDown}
        />
      </td>
    </tr>
  );
}

