"use client";

import { LucideIcon } from "lucide-react";

interface StatCardProps {
  icon: LucideIcon;
  label: string;
  value: string;
  change?: string;
  changeType?: "increase" | "decrease";
}

export default function StatCard({
  icon: Icon,
  label,
  value,
  change,
  changeType,
}: StatCardProps) {
  const isUp = changeType === "increase";

  return (
    <div
      className="
        w-full rounded-2xl
        bg-white 
        border border-black/5 
        shadow-sm 
        hover:shadow-md
        transition-all
        p-6
        flex flex-col gap-4
      "
    >
      <div className="flex items-center justify-between">
        <span className="text-[13px] font-medium text-gray-600">{label}</span>

        <div
          className="
            w-10 h-10 rounded-xl 
            bg-gray-100 
            flex items-center justify-center
            text-gray-700
          "
        >
          <Icon className="w-5 h-5" />
        </div>
      </div>

      <div className="text-[28px] font-semibold text-gray-900 tracking-tight">
        {value}
      </div>

      {change && (
        <div
          className={`
            inline-flex items-center px-2.5 py-1 rounded-md text-[12px] font-medium
            ${isUp ? "text-green-600 bg-green-50" : "text-red-600 bg-red-50"}
          `}
        >
          {isUp ? "↑" : "↓"} {change}
        </div>
      )}
    </div>
  );
}
