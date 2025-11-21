"use client";

import Link from "next/link";
import { LucideIcon } from "lucide-react";

type Tone = "info" | "warning" | "danger";

type TaskItem = {
  title: string;
  value: number;
  icon: LucideIcon;
  href: string;
  tone?: Tone; 
};

interface PendingTasksProps {
  items: TaskItem[];
  title?: string;
  subtitle?: string;
}

const COLORS = {
  info: {
    bg: "bg-indigo-50",
    text: "text-indigo-700",
    icon: "text-indigo-600",
    badge: "bg-indigo-100 text-indigo-700",
  },
  warning: {
    bg: "bg-amber-50",
    text: "text-amber-700",
    icon: "text-amber-600",
    badge: "bg-amber-100 text-amber-700",
  },
  danger: {
    bg: "bg-rose-50",
    text: "text-rose-700",
    icon: "text-rose-600",
    badge: "bg-rose-100 text-rose-700",
  },
};

export default function PendingTasks({
  items,
  title = "Pending Tasks",
  subtitle = "Items requiring admin attention",
}: PendingTasksProps) {
  return (
    <div
      className="
        rounded-2xl bg-white p-6
        border border-black/5
        shadow-sm hover:shadow-md transition-all
      "
    >
      {/* Header */}
      <div className="mb-4">
        <h2 className="text-[18px] font-semibold text-gray-900 tracking-tight">
          {title}
        </h2>
        {subtitle && (
          <p className="text-sm text-gray-500 mt-1">{subtitle}</p>
        )}
      </div>

      <div className="space-y-3">
        {items.map((item, i) => {
          const Icon = item.icon;
          const tone: Tone = item.tone ?? "info";
          const color = COLORS[tone];

          return (
            <Link
              key={i}
              href={item.href}
              className={`
                flex items-center justify-between
                rounded-xl px-3 py-3
                transition-all
                hover:bg-gray-50
                border border-black/5
                ${color.bg}
              `}
            >
              <div className="flex items-center gap-3 min-w-0">
                {/* Icon container */}
                <div
                  className={`
                    w-10 h-10 rounded-lg 
                    flex items-center justify-center 
                    bg-white shadow-sm border border-black/5
                    ${color.icon}
                  `}
                >
                  <Icon className="w-5 h-5" />
                </div>

                {/* Text block */}
                <div className="min-w-0">
                  <p className={`text-sm font-semibold ${color.text}`}>
                    {item.title}
                  </p>
                  <p className="text-xs text-gray-500">View details →</p>
                </div>
              </div>

              {/* Badge */}
              <span
                className={`
                  text-sm font-semibold px-3 py-1
                  rounded-full shadow-sm border border-black/5
                  ${color.badge}
                `}
              >
                {item.value}
              </span>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
