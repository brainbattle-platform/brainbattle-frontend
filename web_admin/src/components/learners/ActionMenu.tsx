"use client";
import { useEffect, useRef, useState } from "react";
import { Eye, Pencil, Trash2, MoreVertical } from "lucide-react";

export function ActionMenu({
  onView,
  onEdit,
  onDelete,
}: {
  onView: () => void;
  onEdit: () => void;
  onDelete: () => void;
}) {
  const [open, setOpen] = useState(false);
  const boxRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (boxRef.current && !boxRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("mousedown", onClick);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onClick);
      document.removeEventListener("keydown", onKey);
    };
  }, []);

  return (
    <div className="relative inline-block" ref={boxRef}>
      <button
        onClick={() => setOpen((v) => !v)}
        aria-haspopup="menu"
        aria-expanded={open}
        className="p-2 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 transition"
      >
        <MoreVertical className="w-4 h-4" />
      </button>

      {open && (
        <div
          role="menu"
          className="absolute right-0 mt-2 w-40 rounded-xl overflow-hidden
          bg-white border border-gray-200 shadow-lg z-20"
        >
          <button
            role="menuitem"
            onClick={() => {
              setOpen(false);
              onView();
            }}
            className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-pink-50 flex items-center gap-2"
          >
            <Eye className="w-4 h-4" /> View profile
          </button>
          <button
            role="menuitem"
            onClick={() => {
              setOpen(false);
              onEdit();
            }}
            className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-pink-50 flex items-center gap-2"
          >
            <Pencil className="w-4 h-4" /> Edit
          </button>
          <button
            role="menuitem"
            onClick={() => {
              setOpen(false);
              onDelete();
            }}
            className="w-full px-3 py-2 text-left text-sm text-rose-600 hover:bg-rose-50 flex items-center gap-2"
          >
            <Trash2 className="w-4 h-4" /> Delete
          </button>
        </div>
      )}
    </div>
  );
}
