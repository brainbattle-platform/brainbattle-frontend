import {
  Mail,
  CheckCircle2,
  XCircle,
  Phone,
  Globe,
  Languages,
  Calendar,
  Smartphone,
} from "lucide-react";
import { UserRow } from "@/types/learners.types";
import { StatusBadge } from "./StatusBadge";
import { ActionMenu } from "./ActionMenu";

const fmtDate = (iso?: string, withTime = true) => {
  if (!iso) return "—";
  const d = new Date(iso);
  return d.toLocaleString(
    "en-US",
    withTime
      ? {
          hour12: false,
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        }
      : { day: "2-digit", month: "2-digit", year: "numeric" }
  );
};

export function LearnerRow({
  u,
  checked,
  onToggle,
}: {
  u: UserRow;
  checked: boolean;
  onToggle: () => void;
}) {
  return (
    <tr className="border-b border-gray-100 hover:bg-gray-50 transition">
      {/* ✅ Checkbox cell (NEW) */}
      <td className="px-3 py-3 w-10 align-top">
        <input
          type="checkbox"
          checked={checked}
          onChange={onToggle}
          className="w-4 h-4 rounded border-gray-300 text-pink-600 focus:ring-pink-400/40"
        />
      </td>

      {/* User cell (GIỮ NGUYÊN) */}
      <td className="px-5 py-3">
        <div className="flex items-start gap-3">
          {/* Avatar: ALWAYS round, never squish */}
          <div className="w-10 h-10 rounded-full overflow-hidden bg-gradient-to-r from-pink-400 to-purple-400 flex items-center justify-center shrink-0">
            {u.avatarUrl ? (
              <img
                src={u.avatarUrl}
                alt={u.name}
                className="w-full h-full object-cover"
              />
            ) : (
              <span className="text-white font-bold uppercase">
                {u.name.trim().charAt(0)}
              </span>
            )}
          </div>

          <div className="space-y-0.5">
            <div className="flex items-center gap-2">
              <span className="text-gray-900 font-medium">{u.name}</span>
              <span className="text-gray-400">•</span>
              <span className="text-gray-500">@{u.username}</span>
            </div>

            <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-gray-600">
              <span className="inline-flex items-center gap-1">
                <Mail className="w-4 h-4 text-gray-400" />
                {u.email}
              </span>

              {u.emailVerified ? (
                <span className="inline-flex items-center gap-1 text-emerald-600">
                  <CheckCircle2 className="w-4 h-4" /> Verified
                </span>
              ) : (
                <span className="inline-flex items-center gap-1 text-amber-600">
                  <XCircle className="w-4 h-4" /> Unverified
                </span>
              )}

              {u.phone && (
                <span className="inline-flex items-center gap-1">
                  <Phone className="w-4 h-4 text-gray-400" /> {u.phone}
                </span>
              )}

              <span className="inline-flex items-center gap-1">
                <Globe className="w-4 h-4 text-gray-400" />
                {u.country} • {u.timezone}
              </span>

              <span className="inline-flex items-center gap-1">
                <Languages className="w-4 h-4 text-gray-400" /> {u.language}
              </span>

              {u.dob && (
                <span className="inline-flex items-center gap-1">
                  <Calendar className="w-4 h-4 text-gray-400" />
                  DOB {fmtDate(u.dob, false)}
                </span>
              )}
            </div>
          </div>
        </div>
      </td>

      {/* UUID (GIỮ NGUYÊN) */}
      <td className="px-5 py-3">
        <code className="text-gray-500 text-xs">{u.id}</code>
      </td>

      {/* Status (GIỮ NGUYÊN) */}
      <td className="px-5 py-3">
        <StatusBadge status={u.status} />
      </td>

      {/* Created (GIỮ NGUYÊN) */}
      <td className="px-5 py-3 text-gray-600">{fmtDate(u.createdAt)}</td>

      {/* Last login (GIỮ NGUYÊN) */}
      <td className="px-5 py-3 text-gray-600">{fmtDate(u.lastLogin)}</td>

      {/* Device (GIỮ NGUYÊN) */}
      <td className="px-5 py-3">
        <span className="inline-flex items-center gap-1.5 text-gray-600">
          <Smartphone className="w-4 h-4 text-gray-400" />
          {u.lastDevice ?? "—"}
        </span>
      </td>

      {/* Actions (GIỮ NGUYÊN) */}
      <td className="px-5 py-3 text-center">
        <ActionMenu
          onView={() => console.log("view", u.id)}
          onEdit={() => console.log("edit", u.id)}
          onDelete={() => console.log("delete", u.id)}
        />
      </td>
    </tr>
  );
}
