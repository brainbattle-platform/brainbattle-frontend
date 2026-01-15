"use client";

import { MoreVertical, Edit, Trash2, Eye, EyeOff } from "lucide-react";
import { useEffect, useRef, useState } from "react";

export function QuestionActionMenu({
  question,
  onEdit,
  onDelete,
  onPublish,
  onUnpublish,
}: {
  question: { id: string; published: boolean };
  onEdit: () => void;
  onDelete: () => void;
  onPublish: () => void;
  onUnpublish: () => void;
}) {
  const [open, setOpen] = useState(false);
  const wrapRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const onClickOutside = (e: MouseEvent) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    };
    const onEsc = (e: KeyboardEvent) => e.key === "Escape" && setOpen(false);

    if (open) {
      document.addEventListener("mousedown", onClickOutside);
      document.addEventListener("keydown", onEsc);
    }
    return () => {
      document.removeEventListener("mousedown", onClickOutside);
      document.removeEventListener("keydown", onEsc);
    };
  }, [open]);

  return (
    <div ref={wrapRef} className="relative">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="p-1.5 rounded-lg hover:bg-gray-100 transition"
        aria-label="Actions"
      >
        <MoreVertical className="w-4 h-4 text-gray-500" />
      </button>

      {open && (
        <div
          className={[
            "absolute right-0 mt-2 w-48 z-20 overflow-hidden rounded-xl",
            "bg-white border border-gray-200 shadow-lg",
            "animate-in fade-in zoom-in-95",
          ].join(" ")}
        >
          <div className="py-1">
            <button
              onClick={() => {
                onEdit();
                setOpen(false);
              }}
              className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
            >
              <Edit className="w-4 h-4" />
              Edit
            </button>

            {question.published ? (
              <button
                onClick={() => {
                  onUnpublish();
                  setOpen(false);
                }}
                className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
              >
                <EyeOff className="w-4 h-4" />
                Unpublish
              </button>
            ) : (
              <button
                onClick={() => {
                  onPublish();
                  setOpen(false);
                }}
                className="w-full px-3 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
              >
                <Eye className="w-4 h-4" />
                Publish
              </button>
            )}

            <div className="border-t border-gray-100 my-1" />

            <button
              onClick={() => {
                if (confirm(`Are you sure you want to delete this question?`)) {
                  onDelete();
                }
                setOpen(false);
              }}
              className="w-full px-3 py-2 text-left text-sm text-red-600 hover:bg-red-50 flex items-center gap-2"
            >
              <Trash2 className="w-4 h-4" />
              Delete
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

