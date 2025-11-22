"use client";

import { useEffect, useRef, useState } from "react";
import {
  MoreHorizontal,
  Eye,
  CheckCircle2,
  XCircle,
  UserCog,
  Trash2,
} from "lucide-react";

export function ActionMenu({
  onView,
  onReview,
  onResolve,
  onReject,
  onAssign,
  onDelete,
}: {
  onView: () => void;
  onReview: () => void;
  onResolve: () => void;
  onReject: () => void;
  onAssign?: () => void;
  onDelete?: () => void;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  // click outside to close
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (!ref.current?.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  const itemCls =
    "flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-gray-700 hover:bg-gray-100 transition w-full text-left";

  return (
    <div ref={ref} className="relative inline-block">
      <button
        onClick={() => setOpen((v) => !v)}
        className="p-2 rounded-lg hover:bg-gray-100 transition"
        title="Actions"
      >
        <MoreHorizontal className="w-5 h-5 text-gray-600" />
      </button>

      {open && (
        <div
          className="
            absolute right-0 mt-2 w-44 z-50
            rounded-xl bg-white border border-gray-200 shadow-lg p-1
            animate-in fade-in zoom-in-95
          "
        >
          <button
            className={itemCls}
            onClick={() => {
              setOpen(false);
              onView();
            }}
          >
            <Eye className="w-4 h-4 text-gray-500" />
            View details
          </button>

          <button
            className={itemCls}
            onClick={() => {
              setOpen(false);
              onReview();
            }}
          >
            <UserCog className="w-4 h-4 text-blue-500" />
            Mark reviewing
          </button>

          <button
            className={itemCls}
            onClick={() => {
              setOpen(false);
              onResolve();
            }}
          >
            <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            Resolve
          </button>

          <button
            className={itemCls}
            onClick={() => {
              setOpen(false);
              onReject();
            }}
          >
            <XCircle className="w-4 h-4 text-amber-600" />
            Reject
          </button>

          {onAssign && (
            <button
              className={itemCls}
              onClick={() => {
                setOpen(false);
                onAssign();
              }}
            >
              <UserCog className="w-4 h-4 text-purple-600" />
              Assign to me
            </button>
          )}

          {onDelete && (
            <button
              className={`${itemCls} text-rose-700 hover:bg-rose-50`}
              onClick={() => {
                setOpen(false);
                onDelete();
              }}
            >
              <Trash2 className="w-4 h-4 text-rose-600" />
              Delete report
            </button>
          )}
        </div>
      )}
    </div>
  );
}
