"use client";

import { useEffect, useMemo, useState } from "react";
import { LearnersHeader } from "@/components/learners/LearnersHeader";
import { LearnersToolbar } from "@/components/learners/LearnersToolbar";
import { LearnersTable } from "@/components/learners/LearnersTable";
import { LearnersStats } from "@/components/learners/LearnersStats";
import { UserRow, AccountStatus } from "@/types/learners.types";
import { mockLearners } from "@/mock/learners.mock";
import { LearnerGrowthChartCard } from "@/components/learners/LearnerGrowthChartCard";
import { LearnerStatusDonutCard } from "@/components/learners/LearnerStatusDonutCard";
import { LearnerBulkActionsBar } from "@/components/learners/LearnerBulkActionsBar";
import { adminAnalyticsApi } from "@/lib/api/admin-analytics";

export default function LearnersPage() {
  const [users, setUsers] = useState<UserRow[]>([]);
  const [q, setQ] = useState("");
  const [status, setStatus] = useState<AccountStatus | "All">("All");
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(false);
  const [userLearningStats, setUserLearningStats] = useState<Record<string, any>>({});

  useEffect(() => {
    // Load mock users (in real app, this would come from auth-service)
    setUsers(mockLearners);
  }, []);

  // Fetch learning stats for users when they are selected or viewed
  useEffect(() => {
    const fetchLearningStats = async () => {
      // For now, we'll fetch stats for all users on mount
      // In a real app, you might want to fetch on-demand when viewing user details
      const stats: Record<string, any> = {};
      
      // Try to extract numeric userId from mock data (if available)
      // Note: mockLearners use UUID strings, but API expects numeric userId
      // This is a limitation - in production, you'd need to map UUID to numeric ID
      // or have the API accept UUID
      
      // For demo purposes, we'll skip fetching if userIds are not numeric
      // In production, you'd have a mapping service or API that accepts UUIDs
      
      setUserLearningStats(stats);
    };

    // Uncomment when you have proper userId mapping:
    // fetchLearningStats();
  }, [users]);

  const filtered = useMemo(() => {
    const text = q.trim().toLowerCase();
    return users.filter((u) => {
      const okStatus = status === "All" || u.status === status;
      const okQ =
        !text ||
        u.name.toLowerCase().includes(text) ||
        u.username.toLowerCase().includes(text) ||
        u.email.toLowerCase().includes(text) ||
        (u.phone ?? "").toLowerCase().includes(text) ||
        u.id.toLowerCase().includes(text);
      return okStatus && okQ;
    });
  }, [users, q, status]);

  // ===== Selection handlers =====
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
      if (checked) filtered.forEach((u) => next.add(u.id));
      else filtered.forEach((u) => next.delete(u.id));
      return next;
    });
  };

  const clearSelection = () => setSelectedIds(new Set());

  const selectedList = useMemo(
    () => users.filter((u) => selectedIds.has(u.id)),
    [users, selectedIds]
  );

  // ===== Bulk actions (mock local) =====
  const bulkActivate = () => {
    setUsers((prev) =>
      prev.map((u) =>
        selectedIds.has(u.id) ? { ...u, status: "active" } : u
      )
    );
    clearSelection();
  };

  const bulkSuspend = () => {
    setUsers((prev) =>
      prev.map((u) =>
        selectedIds.has(u.id) ? { ...u, status: "suspended" } : u
      )
    );
    clearSelection();
  };

  const bulkDelete = () => {
    setUsers((prev) =>
      prev.map((u) =>
        selectedIds.has(u.id) ? { ...u, status: "deleted" } : u
      )
    );
    clearSelection();
  };

  const bulkExportSelected = () => {
    console.log("export selected learners", selectedList);
  };

  return (
    <div className="space-y-5">
      <LearnersHeader />

      <LearnersStats users={users} />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-3">
        <div className="lg:col-span-2">
          <LearnerGrowthChartCard />
        </div>
        <LearnerStatusDonutCard users={users} />
      </div>

      <LearnersToolbar
        q={q}
        setQ={setQ}
        status={status}
        setStatus={setStatus}
        onAdd={() => console.log("add learner")}
        onExport={() => console.log("export csv")}
      />

      {/* ✅ Bulk bar */}
      <LearnerBulkActionsBar
        count={selectedIds.size}
        onActivate={bulkActivate}
        onSuspend={bulkSuspend}
        onDelete={bulkDelete}
        onExport={bulkExportSelected}
        onClear={clearSelection}
      />

      {/* ✅ Table with selection */}
      <LearnersTable
        users={filtered}
        selectedIds={selectedIds}
        onToggleSelect={toggleSelect}
        onToggleAll={toggleAllVisible}
      />

      <div className="flex items-center justify-between text-sm text-gray-500">
        <span>Showing {filtered.length} of {users.length} learners</span>
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
