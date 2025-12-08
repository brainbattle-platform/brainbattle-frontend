"use client";

import { useEffect, useMemo, useState } from "react";
import type {
  ViolationRow,
  ViolationStatus,
  ViolationSeverity,
  ViolationType,
} from "@/types/violations.types";
import { mockViolations } from "@/mock/violations.mock";

import { ViolationsHeader } from "@/components/violations/ViolationsHeader";
import { ViolationsStats } from "@/components/violations/ViolationsStats";
import { ViolationsChartsRow } from "@/components/violations/ViolationsChartsRow";
import { ViolationsToolbar } from "@/components/violations/ViolationsToolbar";
import { ViolationBulkActionsBar } from "@/components/violations/ViolationBulkActionsBar";
import { ViolationsTable } from "@/components/violations/ViolationsTable";

export default function ViolationReportsPage() {
  const [items, setItems] = useState<ViolationRow[]>([]);
  const [q, setQ] = useState("");
  const [status, setStatus] = useState<ViolationStatus | "All">("All");
  const [severity, setSeverity] = useState<ViolationSeverity | "All">("All");
  const [type, setType] = useState<ViolationType | "All">("All");
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  useEffect(() => setItems(mockViolations), []);

  const filtered = useMemo(() => {
    const text = q.trim().toLowerCase();
    return items.filter((i) => {
      const okStatus = status === "All" || i.status === status;
      const okSeverity = severity === "All" || i.severity === severity;
      const okType = type === "All" || i.type === type;

      const okQ =
        !text ||
        i.id.toLowerCase().includes(text) ||
        i.reporterName.toLowerCase().includes(text) ||
        i.reportedUserName.toLowerCase().includes(text) ||
        i.contentPreview?.toLowerCase().includes(text) ||
        i.contentId.toLowerCase().includes(text);

      return okStatus && okSeverity && okType && okQ;
    });
  }, [items, q, status, severity, type]);

  // selection
  const toggleSelect = (id: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const toggleAllVisible = (checked: boolean) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (checked) filtered.forEach((i) => next.add(i.id));
      else filtered.forEach((i) => next.delete(i.id));
      return next;
    });
  };

  const clearSelection = () => setSelectedIds(new Set());

  // bulk actions (mock local)
  const bulkResolve = () => {
    setItems((prev) =>
      prev.map((i) =>
        selectedIds.has(i.id)
          ? {
              ...i,
              status: "resolved",
              lastUpdatedAt: new Date().toISOString(),
            }
          : i
      )
    );
    clearSelection();
  };

  const bulkReject = () => {
    setItems((prev) =>
      prev.map((i) =>
        selectedIds.has(i.id)
          ? {
              ...i,
              status: "rejected",
              lastUpdatedAt: new Date().toISOString(),
            }
          : i
      )
    );
    clearSelection();
  };

  const bulkAssign = () => {
    setItems((prev) =>
      prev.map((i) =>
        selectedIds.has(i.id)
          ? {
              ...i,
              status: "reviewing",
              assignedTo: "You",
              lastUpdatedAt: new Date().toISOString(),
            }
          : i
      )
    );
    clearSelection();
  };

  const bulkDelete = () => {
    setItems((prev) => prev.filter((i) => !selectedIds.has(i.id)));
    clearSelection();
  };

  const bulkExportSelected = () => {
    const list = items.filter((i) => selectedIds.has(i.id));
    console.log("export selected violations", list);
  };

  return (
    <div className="space-y-5">
      <ViolationsHeader
        onExport={() => console.log("export all CSV")}
        onQueue={() => console.log("open moderation queue")}
      />

      <ViolationsStats items={items} />

      {/* equal-height charts row */}
      <ViolationsChartsRow items={items} />

      <ViolationsToolbar
        q={q}
        setQ={setQ}
        status={status}
        setStatus={setStatus}
        severity={severity}
        setSeverity={setSeverity}
        type={type}
        setType={setType}
      />

      <ViolationBulkActionsBar
        count={selectedIds.size}
        onResolve={bulkResolve}
        onReject={bulkReject}
        onAssign={bulkAssign}
        onDelete={bulkDelete}
        onExport={bulkExportSelected}
        onClear={clearSelection}
      />

      <ViolationsTable
        items={filtered}
        selectedIds={selectedIds}
        onToggleSelect={toggleSelect}
        onToggleAll={toggleAllVisible}
      />

      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>
          Showing {filtered.length} of {items.length} reports
        </span>
        <div className="flex gap-2">
          <button className="px-3 py-1 rounded-lg bg-gray-100 hover:bg-gray-200">
            Previous
          </button>
          <button className="px-3 py-1 rounded-lg bg-gray-100 hover:bg-gray-200">
            Next
          </button>
        </div>
      </div>
    </div>
  );
}
