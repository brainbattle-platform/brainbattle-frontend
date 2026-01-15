"use client";

import { Search, Filter, ChevronDown, Download, Plus, Check } from "lucide-react";
import { useEffect, useMemo, useRef, useState } from "react";

type PublishedFilter = "All" | "Published" | "Draft";
type ModeFilter = "All" | "listening" | "speaking" | "reading" | "writing";

const PUBLISHED_OPTIONS: { label: string; value: PublishedFilter }[] = [
  { label: "All questions", value: "All" },
  { label: "Published", value: "Published" },
  { label: "Draft", value: "Draft" },
];

const MODE_OPTIONS: { label: string; value: ModeFilter }[] = [
  { label: "All modes", value: "All" },
  { label: "Listening", value: "listening" },
  { label: "Speaking", value: "speaking" },
  { label: "Reading", value: "reading" },
  { label: "Writing", value: "writing" },
];

function PublishedFilter({
  value,
  onChange,
}: {
  value: PublishedFilter;
  onChange: (v: PublishedFilter) => void;
}) {
  const [open, setOpen] = useState(false);
  const wrapRef = useRef<HTMLDivElement | null>(null);

  const current = useMemo(
    () => PUBLISHED_OPTIONS.find((o) => o.value === value) ?? PUBLISHED_OPTIONS[0],
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
      >
        <Filter className="w-4 h-4 text-gray-400" />
        <span className="text-gray-800">{current.label}</span>
        <ChevronDown className="w-4 h-4 text-gray-400" />
      </button>

      {open && (
        <div
          className={[
            "absolute right-0 mt-2 w-44 z-20 overflow-hidden rounded-2xl",
            "bg-white border border-gray-200 shadow-lg",
          ].join(" ")}
        >
          {PUBLISHED_OPTIONS.map((opt) => {
            const active = opt.value === value;
            return (
              <button
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

function ModeFilter({
  value,
  onChange,
}: {
  value: ModeFilter;
  onChange: (v: ModeFilter) => void;
}) {
  const [open, setOpen] = useState(false);
  const wrapRef = useRef<HTMLDivElement | null>(null);

  const current = useMemo(
    () => MODE_OPTIONS.find((o) => o.value === value) ?? MODE_OPTIONS[0],
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
      >
        <Filter className="w-4 h-4 text-gray-400" />
        <span className="text-gray-800">{current.label}</span>
        <ChevronDown className="w-4 h-4 text-gray-400" />
      </button>

      {open && (
        <div
          className={[
            "absolute right-0 mt-2 w-44 z-20 overflow-hidden rounded-2xl",
            "bg-white border border-gray-200 shadow-lg",
          ].join(" ")}
        >
          {MODE_OPTIONS.map((opt) => {
            const active = opt.value === value;
            return (
              <button
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

export function QuestionsToolbar({
  q,
  setQ,
  published,
  setPublished,
  mode,
  setMode,
  onAdd,
  onExport,
}: {
  q: string;
  setQ: (v: string) => void;
  published: PublishedFilter;
  setPublished: (v: PublishedFilter) => void;
  mode: ModeFilter;
  setMode: (v: ModeFilter) => void;
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
            placeholder="Search by question ID, prompt, lesson ID…"
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
          {/* Mode Filter */}
          <ModeFilter value={mode} onChange={setMode} />

          {/* Published Filter */}
          <PublishedFilter value={published} onChange={setPublished} />

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

          {/* Add question */}
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
            <Plus className="w-4 h-4" />
            Add Question
          </button>
        </div>
      </div>
    </div>
  );
}

