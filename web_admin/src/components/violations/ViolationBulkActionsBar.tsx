"use client";

import { CheckCircle2, XCircle, Trash2, Download, UserCog, X } from "lucide-react";

export function ViolationBulkActionsBar({
  count,
  onResolve,
  onReject,
  onDelete,
  onAssign,
  onExport,
  onClear,
}: {
  count: number;
  onResolve: () => void;
  onReject: () => void;
  onDelete: () => void;
  onAssign: () => void;
  onExport: () => void;
  onClear: () => void;
}) {
  if (count === 0) return null;

  return (
    <div className="sticky top-[72px] z-20 rounded-2xl bg-white border border-gray-200 shadow-sm px-4 py-3 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
      <div className="flex items-center gap-2 text-sm">
        <span className="font-semibold text-gray-900">{count} selected</span>
        <span className="text-gray-400">•</span>
        <button onClick={onClear} className="inline-flex items-center gap-1 text-gray-500 hover:text-gray-800">
          <X className="w-4 h-4" /> Clear
        </button>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <button onClick={onResolve} className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100 transition">
          <CheckCircle2 className="w-4 h-4" /> Resolve
        </button>

        <button onClick={onReject} className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium bg-amber-50 text-amber-700 border border-amber-200 hover:bg-amber-100 transition">
          <XCircle className="w-4 h-4" /> Reject
        </button>

        <button onClick={onAssign} className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium bg-blue-50 text-blue-700 border border-blue-200 hover:bg-blue-100 transition">
          <UserCog className="w-4 h-4" /> Assign
        </button>

        <button onClick={onDelete} className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium bg-rose-50 text-rose-700 border border-rose-200 hover:bg-rose-100 transition">
          <Trash2 className="w-4 h-4" /> Delete
        </button>

        <button onClick={onExport} className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium bg-gray-100 text-gray-700 hover:bg-gray-200 transition">
          <Download className="w-4 h-4" /> Export selected
        </button>
      </div>
    </div>
  );
}
