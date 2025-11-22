import { AlertTriangle, MessageSquareText, Video, User } from "lucide-react";
import type { ViolationRow } from "@/types/violations.types";
import { SeverityBadge } from "./SeverityBadge";
import { StatusBadge } from "./StatusBadge";
import { ActionMenu } from "./ActionMenu";

const fmtDate = (iso?: string) => {
  if (!iso) return "—";
  return new Date(iso).toLocaleString("en-US", {
    hour12: false,
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const contentIcon = (t: ViolationRow["contentType"]) => {
  if (t === "video") return <Video className="w-4 h-4 text-gray-400" />;
  if (t === "comment" || t === "message")
    return <MessageSquareText className="w-4 h-4 text-gray-400" />;
  return <User className="w-4 h-4 text-gray-400" />;
};

const prettyType = (t: string) =>
  t
    .split("_")
    .map((x) => x[0]?.toUpperCase() + x.slice(1))
    .join(" ");

export function ViolationRowItem({
  item,
  checked,
  onToggle,
}: {
  item: ViolationRow;
  checked: boolean;
  onToggle: () => void;
}) {
  return (
    <tr className="border-b border-gray-100 hover:bg-gray-50/70 transition-colors">
      {/* Checkbox */}
      <td className="px-3 py-3 w-10 align-top">
        <input
          type="checkbox"
          checked={checked}
          onChange={onToggle}
          className="w-4 h-4 rounded border-gray-300 text-pink-600 focus:ring-pink-400/40"
        />
      </td>

      {/* Report cell */}
      <td className="px-5 py-3">
        <div className="flex items-start gap-3">
          {/* thumb */}
          <div className="w-10 h-10 rounded-full overflow-hidden bg-gray-100 shrink-0 ring-1 ring-gray-200">
            {item.contentThumbUrl ? (
              <img
                src={item.contentThumbUrl}
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <AlertTriangle className="w-5 h-5 text-gray-400" />
              </div>
            )}
          </div>

          <div className="space-y-1">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="font-semibold text-gray-900">
                {item.id}
              </span>

              <span className="text-gray-400">•</span>

              <span className="text-xs text-gray-500 inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-gray-100">
                {contentIcon(item.contentType)}
                {prettyType(item.contentType)}
              </span>
            </div>

            <div className="text-xs text-gray-600 line-clamp-2 max-w-[560px] leading-relaxed">
              {item.contentPreview ?? "—"}
            </div>

            <div className="text-xs text-gray-500">
              Reporter:{" "}
              <span className="text-gray-700 font-medium">
                {item.reporterName}
              </span>{" "}
              (@{item.reporterUsername})
              {" • "}
              Reported:{" "}
              <span className="text-gray-700 font-medium">
                {item.reportedUserName}
              </span>{" "}
              (@{item.reportedUserUsername})
            </div>
          </div>
        </div>
      </td>

      {/* Type */}
      <td className="px-5 py-3 text-gray-700">
        {prettyType(item.type)}
      </td>

      {/* Severity */}
      <td className="px-5 py-3">
        <SeverityBadge severity={item.severity} />
      </td>

      {/* Status */}
      <td className="px-5 py-3">
        <StatusBadge status={item.status} />
      </td>

      {/* Created at */}
      <td className="px-5 py-3 text-gray-600 whitespace-nowrap">
        {fmtDate(item.createdAt)}
      </td>

      {/* Assigned */}
      <td className="px-5 py-3 text-gray-600 whitespace-nowrap">
        {item.assignedTo ?? "—"}
      </td>

      {/* Actions */}
      <td className="px-5 py-3 text-center">
        <ActionMenu
          onView={() => console.log("view", item.id)}
          onReview={() => console.log("review", item.id)}
          onResolve={() => console.log("resolve", item.id)}
          onReject={() => console.log("reject", item.id)}
        />
      </td>
    </tr>
  );
}
