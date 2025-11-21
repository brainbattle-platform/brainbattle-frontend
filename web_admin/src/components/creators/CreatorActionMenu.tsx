"use client";
import { useEffect, useRef, useState } from "react";
import { Eye, ShieldCheck, ShieldBan, MoreVertical } from "lucide-react";

export function CreatorActionMenu({
  onView,
  onApprove,
  onSuspend,
}: {
  onView: () => void;
  onApprove: () => void;
  onSuspend: () => void;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const close = (e: MouseEvent) => ref.current && !ref.current.contains(e.target as Node) && setOpen(false);
    document.addEventListener("mousedown", close);
    return () => document.removeEventListener("mousedown", close);
  }, []);

  return (
    <div className="relative inline-block" ref={ref}>
      <button
        onClick={() => setOpen(v => !v)}
        className="p-2 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 transition"
      >
        <MoreVertical className="w-4 h-4" />
      </button>

      {open && (
        <div className="absolute right-0 mt-2 w-44 rounded-xl overflow-hidden bg-white border border-gray-200 shadow-lg z-20">
          <button onClick={() => { setOpen(false); onView(); }}
            className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-pink-50 flex items-center gap-2">
            <Eye className="w-4 h-4" /> View profile
          </button>
          <button onClick={() => { setOpen(false); onApprove(); }}
            className="w-full px-3 py-2 text-left text-sm text-emerald-700 hover:bg-emerald-50 flex items-center gap-2">
            <ShieldCheck className="w-4 h-4" /> Approve / Verify
          </button>
          <button onClick={() => { setOpen(false); onSuspend(); }}
            className="w-full px-3 py-2 text-left text-sm text-rose-700 hover:bg-rose-50 flex items-center gap-2">
            <ShieldBan className="w-4 h-4" /> Suspend
          </button>
        </div>
      )}
    </div>
  );
}
