"use client";

import { useEffect, useRef, useState } from "react";
import {
  Filter,
  Search,
  SlidersHorizontal,
  Shapes,
  ChevronDown,
  Check,
} from "lucide-react";
import type {
  ViolationStatus,
  ViolationSeverity,
  ViolationType,
} from "@/types/violations.types";

export function ViolationsToolbar({
  q,
  setQ,
  status,
  setStatus,
  severity,
  setSeverity,
  type,
  setType,
}: {
  q: string;
  setQ: (v: string) => void;

  status: ViolationStatus | "All";
  setStatus: (v: ViolationStatus | "All") => void;

  severity: ViolationSeverity | "All";
  setSeverity: (v: ViolationSeverity | "All") => void;

  type: ViolationType | "All";
  setType: (v: ViolationType | "All") => void;
}) {
  return (
    <div
      className="
        rounded-2xl bg-white border border-gray-200 shadow-sm
        p-3 flex flex-col lg:flex-row lg:items-center gap-2 lg:gap-3
      "
    >
      {/* Search */}
      <div
        className="
          flex items-center gap-2 flex-1 px-3 h-11 rounded-xl
          bg-gray-50 border border-gray-200
          focus-within:ring-2 focus-within:ring-pink-400/40
          transition
        "
      >
        <Search className="w-4 h-4 text-gray-400" />
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Search by report ID, user, content, or keyword..."
          className="flex-1 bg-transparent outline-none text-sm text-gray-800 placeholder:text-gray-400"
        />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-2">
        <CreatorSelect
          icon={<Filter className="w-4 h-4 text-gray-500" />}
          value={status}
          onChange={(v) => setStatus(v as any)}
          options={[
            { value: "All", label: "All statuses" },
            { value: "pending", label: "Pending" },
            { value: "reviewing", label: "Reviewing" },
            { value: "resolved", label: "Resolved" },
            { value: "rejected", label: "Rejected" },
          ]}
        />

        <CreatorSelect
          icon={<SlidersHorizontal className="w-4 h-4 text-gray-500" />}
          value={severity}
          onChange={(v) => setSeverity(v as any)}
          options={[
            { value: "All", label: "All severities" },
            { value: "low", label: "Low" },
            { value: "medium", label: "Medium" },
            { value: "high", label: "High" },
            { value: "critical", label: "Critical" },
          ]}
        />

        <CreatorSelect
          icon={<Shapes className="w-4 h-4 text-gray-500" />}
          value={type}
          onChange={(v) => setType(v as any)}
          options={[
            { value: "All", label: "All types" },
            { value: "spam", label: "Spam" },
            { value: "harassment", label: "Harassment" },
            { value: "hate_speech", label: "Hate speech" },
            { value: "nudity", label: "Nudity" },
            { value: "violence", label: "Violence" },
            { value: "copyright", label: "Copyright" },
            { value: "other", label: "Other" },
          ]}
        />
      </div>
    </div>
  );
}

function CreatorSelect({
  icon,
  value,
  onChange,
  options,
}: {
  icon: React.ReactNode;
  value: string;
  onChange: (v: string) => void;
  options: { value: string; label: string }[];
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  const selected = options.find((o) => o.value === value) ?? options[0];

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (!ref.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  return (
    <div ref={ref} className="relative">
      {/* Trigger */}
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="
          inline-flex items-center gap-2 h-11 px-3 rounded-xl
          bg-white border border-gray-200 shadow-sm text-sm
          hover:bg-gray-50 transition
          focus:outline-none focus:ring-2 focus:ring-pink-400/40
        "
      >
        {icon}
        <span className="font-medium text-gray-800">{selected.label}</span>
        <ChevronDown className="w-4 h-4 text-gray-400 ml-1" />
      </button>

      {/* Menu */}
      {open && (
        <div
          className="
            absolute right-0 mt-2 w-56 z-50
            rounded-2xl bg-white border border-gray-200 shadow-xl
            overflow-hidden
          "
        >
          {options.map((o) => {
            const active = o.value === value;
            return (
              <button
                key={o.value}
                onClick={() => {
                  onChange(o.value);
                  setOpen(false);
                }}
                className={[
                  "w-full px-4 py-2.5 text-left text-sm flex items-center justify-between transition",
                  active
                    ? "bg-pink-50 text-pink-600 font-semibold"
                    : "text-gray-700 hover:bg-gray-50",
                ].join(" ")}
              >
                <span>{o.label}</span>
                {active && <Check className="w-4 h-4" />}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}
