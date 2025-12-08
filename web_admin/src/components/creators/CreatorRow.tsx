import {
  Mail, Globe, Languages, Users, BookOpen, Star, DollarSign, Smartphone, BadgeCheck
} from "lucide-react";
import type { CreatorRow as CreatorRowType } from "@/types/creators.types";
import { CreatorStatusBadge, AccessLevelBadge } from "./CreatorBadges";
import { CreatorActionMenu } from "./CreatorActionMenu";

const fmtDate = (iso?: string) => {
  if (!iso) return "—";
  return new Date(iso).toLocaleString("en-US", {
    hour12: false, day: "2-digit", month: "2-digit", year: "numeric",
    hour: "2-digit", minute: "2-digit",
  });
};

export function CreatorRow({
  c,
  selected,
  onToggleSelect,
}: {
  c: CreatorRowType;
  selected: boolean;
  onToggleSelect: (id: string) => void;
}) {
  return (
    <tr className="border-b border-gray-100 hover:bg-gray-50 transition">
      {/* checkbox */}
      <td className="px-3 py-3 w-10">
        <input
          type="checkbox"
          checked={selected}
          onChange={() => onToggleSelect(c.id)}
          className="w-4 h-4 rounded border-gray-300 text-pink-600 focus:ring-pink-400/40"
        />
      </td>

      {/* creator */}
      <td className="px-5 py-3">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-full overflow-hidden bg-gradient-to-r from-pink-400 to-purple-400 shrink-0">
            {c.avatarUrl ? (
              <img src={c.avatarUrl} alt={c.name} className="w-full h-full object-cover" />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-white font-bold">
                {c.name.charAt(0)}
              </div>
            )}
          </div>

          <div className="space-y-0.5">
            <div className="flex items-center gap-2">
              <span className="text-gray-900 font-medium">{c.name}</span>
              <span className="text-gray-400">•</span>
              <span className="text-gray-500">@{c.username}</span>
              {c.kycVerified && (
                <span className="inline-flex items-center gap-1 text-emerald-600 text-xs">
                  <BadgeCheck className="w-3.5 h-3.5" /> KYC
                </span>
              )}
            </div>

            <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-gray-600 text-sm">
              <span className="inline-flex items-center gap-1">
                <Mail className="w-4 h-4 text-gray-400" /> {c.email}
              </span>
              <span className="inline-flex items-center gap-1">
                <Globe className="w-4 h-4 text-gray-400" /> {c.country} • {c.timezone}
              </span>
              <span className="inline-flex items-center gap-1">
                <Languages className="w-4 h-4 text-gray-400" /> {c.language}
              </span>
            </div>
          </div>
        </div>
      </td>

      <td className="px-5 py-3">
        <code className="text-gray-500 text-xs">{c.id}</code>
      </td>

      <td className="px-5 py-3">
        <div className="flex items-center gap-2">
          <CreatorStatusBadge status={c.status} />
          <AccessLevelBadge level={c.accessLevel} />
        </div>
      </td>

      <td className="px-5 py-3 text-gray-700">
        <div className="flex items-center gap-2">
          <BookOpen className="w-4 h-4 text-gray-400" />
          {c.courses}
        </div>
      </td>

      <td className="px-5 py-3 text-gray-700">
        <div className="flex items-center gap-2">
          <Users className="w-4 h-4 text-gray-400" />
          {c.students.toLocaleString()}
        </div>
      </td>

      <td className="px-5 py-3 text-gray-700">
        <div className="flex items-center gap-2">
          <Star className="w-4 h-4 text-amber-500" />
          {c.avgRating.toFixed(1)}
        </div>
      </td>

      <td className="px-5 py-3 text-gray-700 font-medium">
        <div className="flex items-center gap-2">
          <DollarSign className="w-4 h-4 text-purple-500" />
          ${c.totalRevenueUsd.toLocaleString()}
        </div>
      </td>

      <td className="px-5 py-3 text-gray-600">{fmtDate(c.createdAt)}</td>
      <td className="px-5 py-3 text-gray-600">{fmtDate(c.lastActiveAt)}</td>

      <td className="px-5 py-3">
        <span className="inline-flex items-center gap-1.5 text-gray-600">
          <Smartphone className="w-4 h-4 text-gray-400" />
          {c.lastDevice ?? "—"}
        </span>
      </td>

      <td className="px-5 py-3 text-center">
        <CreatorActionMenu
          onView={() => console.log("view", c.id)}
          onApprove={() => console.log("approve", c.id)}
          onSuspend={() => console.log("suspend", c.id)}
        />
      </td>
    </tr>
  );
}
