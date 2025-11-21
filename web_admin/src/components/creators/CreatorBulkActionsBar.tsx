"use client";

import { Download, X, ShieldCheck, ShieldBan } from "lucide-react";

export function CreatorBulkActionsBar({
  count, onApprove, onSuspend, onExport, onClear
}:{
  count: number;
  onApprove: ()=>void;
  onSuspend: ()=>void;
  onExport: ()=>void;
  onClear: ()=>void;
}) {
  if (count === 0) return null;

  return (
    <div className="sticky top-[72px] z-20 rounded-2xl bg-white border border-gray-200 shadow-sm px-4 py-3
      flex flex-col md:flex-row md:items-center md:justify-between gap-3"
    >
      <div className="flex items-center gap-2 text-sm">
        <span className="font-semibold text-gray-900">{count} selected</span>
        <span className="text-gray-400">•</span>
        <button onClick={onClear} className="inline-flex items-center gap-1 text-gray-500 hover:text-gray-800">
          <X className="w-4 h-4" /> Clear selection
        </button>
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <button
          onClick={onApprove}
          className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium
          bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100 transition"
        >
          <ShieldCheck className="w-4 h-4" /> Approve / Verify
        </button>

        <button
          onClick={onSuspend}
          className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium
          bg-rose-50 text-rose-700 border border-rose-200 hover:bg-rose-100 transition"
        >
          <ShieldBan className="w-4 h-4" /> Suspend selected
        </button>

        <button
          onClick={onExport}
          className="inline-flex items-center gap-2 h-10 px-3 rounded-xl text-sm font-medium
          bg-gray-100 text-gray-700 hover:bg-gray-200 transition"
        >
          <Download className="w-4 h-4" /> Export selected
        </button>
      </div>
    </div>
  );
}
