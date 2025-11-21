"use client";

import { useEffect, useMemo, useState } from "react";
import type { CreatorRow, CreatorStatus } from "@/types/creators.types";
import { mockCreators } from "@/mock/creators.mock";

import { CreatorsHeader } from "@/components/creators/CreatorsHeader";
import { CreatorsStats } from "@/components/creators/CreatorsStats";
import { CreatorSpotlightGrid } from "@/components/creators/CreatorSpotlightGrid";
import { CreatorRevenueTrendCard } from "@/components/creators/CreatorRevenueTrendCard";
import { CreatorStatusDonutCard } from "@/components/creators/CreatorStatusDonutCard";
import { CreatorAccessFunnelCard } from "@/components/creators/CreatorAccessFunnelCard";
import { CreatorsToolbar } from "@/components/creators/CreatorsToolbar";
import { CreatorBulkActionsBar } from "@/components/creators/CreatorBulkActionsBar";
import { CreatorsTable } from "@/components/creators/CreatorsTable";

export default function CreatorsPage() {
  const [creators, setCreators] = useState<CreatorRow[]>([]);
  const [q, setQ] = useState("");
  const [status, setStatus] = useState<CreatorStatus | "All">("All");
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());

  useEffect(() => setCreators(mockCreators), []);

  const filtered = useMemo(() => {
    const text = q.trim().toLowerCase();
    return creators.filter(c => {
      const okStatus = status === "All" || c.status === status;
      const okQ =
        !text ||
        c.name.toLowerCase().includes(text) ||
        c.username.toLowerCase().includes(text) ||
        c.email.toLowerCase().includes(text) ||
        c.id.toLowerCase().includes(text);
      return okStatus && okQ;
    });
  }, [creators, q, status]);

  // selection
  const toggleSelect = (id: string) => {
    setSelectedIds(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const toggleAllVisible = (checked: boolean) => {
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (checked) filtered.forEach(c => next.add(c.id));
      else filtered.forEach(c => next.delete(c.id));
      return next;
    });
  };

  const clearSelection = () => setSelectedIds(new Set());

  const selectedList = useMemo(
    () => creators.filter(c => selectedIds.has(c.id)),
    [creators, selectedIds]
  );

  // bulk actions (mock local)
  const bulkApprove = () => {
    setCreators(prev =>
      prev.map(c =>
        selectedIds.has(c.id)
          ? { ...c, status: "active", accessLevel: "verified", kycVerified: true }
          : c
      )
    );
    clearSelection();
  };

  const bulkSuspend = () => {
    setCreators(prev =>
      prev.map(c =>
        selectedIds.has(c.id) ? { ...c, status: "suspended" } : c
      )
    );
    clearSelection();
  };

  const bulkExportSelected = () => {
    console.log("export selected creators", selectedList);
  };

  return (
    <div className="space-y-5">
      <CreatorsHeader />

      <CreatorsStats creators={creators} />

      {/* New-lạ hơn Learner: Spotlight */}
      <CreatorSpotlightGrid creators={creators} />

      {/* Charts row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-3">
        <div className="lg:col-span-2 space-y-3">
          <CreatorRevenueTrendCard />
          <CreatorAccessFunnelCard creators={creators} />
        </div>
        <CreatorStatusDonutCard creators={creators} />
      </div>

      <CreatorsToolbar
        q={q}
        setQ={setQ}
        status={status}
        setStatus={setStatus}
        onAdd={() => console.log("invite creator")}
        onExport={() => console.log("export creators csv")}
      />

      <CreatorBulkActionsBar
        count={selectedIds.size}
        onApprove={bulkApprove}
        onSuspend={bulkSuspend}
        onExport={bulkExportSelected}
        onClear={clearSelection}
      />

      <CreatorsTable
        creators={filtered}
        selectedIds={selectedIds}
        onToggleSelect={toggleSelect}
        onToggleAll={toggleAllVisible}
      />

      {/* Pagination placeholder */}
      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>Showing {filtered.length} of {creators.length} creators</span>
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
