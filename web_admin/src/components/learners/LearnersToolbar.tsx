"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { Search, Filter, ChevronDown, Download, UserPlus2, Check } from "lucide-react";
import type { AccountStatus } from "@/types/learners.types";

type StatusOption = { label: string; value: AccountStatus | "All" };

const STATUS_OPTIONS: StatusOption[] = [
  { label: "All statuses", value: "All" },
  { label: "Active", value: "active" },
  { label: "Suspended", value: "suspended" },
  { label: "Deleted", value: "deleted" },
];

function StatusFilter({
  value,
  onChange,
}: {
  value: AccountStatus | "All";
  onChange: (v: AccountStatus | "All") => void;
}) {
  const [open, setOpen] = useState(false);
  const wrapRef = useRef<HTMLDivElement | null>(null);

  const current = useMemo(
    () => STATUS_OPTIONS.find((o) => o.value === value) ?? STATUS_OPTIONS[0],
    [value]
  );

  useEffect(() => {
    const onClickOutside = (e: MouseEvent) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    const onEsc = (e: KeyboardEvent) => e.key === "Escape" && setOpen(false);

    document.addEventListener("mousedown", onClickOutside);
    document.addEventListener("keydown", onEsc);
    return () => {
      document.removeEventListener("mousedown", onClickOutside);
      document.removeEventListener("keydown", onEsc);
    };
  }, []);

  return (
    <div ref={wrapRef} className="relative">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className={[
          "inline-flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-medium",
          "bg-white border border-gray-200 shadow-sm",
          "hover:border-pink-300 hover:shadow transition",
          "focus:outline-none focus:ring-2 focus:ring-pink-400/40",
        ].join(" ")}
        aria-haspopup="listbox"
        aria-expanded={open}
      >
        <Filter className="w-4 h-4 text-gray-400" />
        <span className="text-gray-800">{current.label}</span>
        <ChevronDown className="w-4 h-4 text-gray-400" />
      </button>

      {open && (
        <div
          role="listbox"
          className={[
            "absolute right-0 mt-2 w-44 z-20 overflow-hidden rounded-2xl",
            "bg-white border border-gray-200 shadow-lg",
            "animate-in fade-in zoom-in-95",
          ].join(" ")}
        >
          {STATUS_OPTIONS.map((opt) => {
            const active = opt.value === value;
            return (
              <button
                role="option"
                aria-selected={active}
                key={opt.value}
                onClick={() => {
                  onChange(opt.value);
                  setOpen(false);
                }}
                className={[
                  "w-full px-3 py-2.5 text-left text-sm flex items-center justify-between",
                  active
                    ? "bg-pink-50 text-pink-700"
                    : "text-gray-700 hover:bg-gray-50",
                ].join(" ")}
              >
                <span>{opt.label}</span>
                {active && <Check className="w-4 h-4" />}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

export function LearnersToolbar({
  q,
  setQ,
  status,
  setStatus,
  onAdd,
  onExport,
}: {
  q: string;
  setQ: (v: string) => void;
  status: AccountStatus | "All";
  setStatus: (v: AccountStatus | "All") => void;
  onAdd: () => void;
  onExport: () => void;
}) {
  return (
    <div className="rounded-2xl p-4 bg-white border border-gray-200 shadow-sm">
      <div className="flex flex-col lg:flex-row lg:items-center gap-3 lg:gap-4 justify-between">
        {/* Search */}
        <div className="relative flex-1">
          <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search by name, username, email, phone or UUID…"
            className={[
              "w-full h-11 pl-9 pr-3 rounded-xl text-sm",
              "bg-gray-50 border border-gray-200",
              "text-gray-900 placeholder:text-gray-400",
              "focus:outline-none focus:ring-2 focus:ring-pink-400/40 focus:border-pink-300",
              "transition",
            ].join(" ")}
          />
        </div>

        {/* Right controls */}
        <div className="flex flex-wrap items-center gap-2 lg:gap-3">
          {/* Status Filter */}
          <StatusFilter value={status} onChange={setStatus} />

          {/* Export */}
          <button
            onClick={onExport}
            className={[
              "inline-flex items-center gap-2 h-11 px-3 rounded-xl text-sm font-medium",
              "bg-gray-100 text-gray-700 hover:bg-gray-200",
              "border border-transparent hover:border-gray-200",
              "transition",
            ].join(" ")}
          >
            <Download className="w-4 h-4" />
            Export CSV
          </button>

          {/* Add learner */}
          <button
            onClick={onAdd}
            className={[
              "inline-flex items-center gap-2 h-11 px-4 rounded-xl text-sm font-semibold text-white",
              "bg-gradient-to-r from-pink-500 to-purple-500",
              "shadow-sm hover:shadow hover:opacity-95 active:opacity-90",
              "focus:outline-none focus:ring-2 focus:ring-pink-400/50",
              "transition",
            ].join(" ")}
          >
            <UserPlus2 className="w-4 h-4" />
            Add learner
          </button>
        </div>
      </div>
    </div>
  );
}
