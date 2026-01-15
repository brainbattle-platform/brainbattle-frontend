"use client";

import { useMemo, useState, useEffect } from "react";

import StatCard from "@/components/dashboard/StatCard";
import RangeFilter, { RangeKey } from "@/components/dashboard/RangeFilter";
import ModelFilter, { ModelKey } from "@/components/dashboard/ModelFilter";
import TrendChartCard from "@/components/dashboard/TrendChartCard";
import DonutChartCard from "@/components/dashboard/DonutChartCard";
import PendingTasks from "@/components/dashboard/PendingTasks";
import TopLessons from "@/components/dashboard/TopLessons";
import NeedsAttention from "@/components/dashboard/NeedsAttention";
import RealtimeFeed from "@/components/dashboard/RealtimeFeed";

import {
  Eye,
  Target,
  Award,
  MessageCircle,
  Users,
  PlayCircle,
  ClipboardList,
  AlertTriangle,
} from "lucide-react";

import {
  donutData,
  pendingTasks,
  needsAttention,
  realtimeFeed,
} from "@/mock/dashboard.mock";

import { adminAnalyticsApi } from "@/lib/api/admin-analytics";
import type { TimeseriesPoint } from "@/lib/api/admin-analytics";

type TabKey = "attempts" | "completions";

// Helper to get date range from RangeKey
function getDateRange(range: RangeKey): { from?: string; to?: string } {
  const today = new Date();
  const to = today.toISOString().split("T")[0]; // YYYY-MM-DD

  if (range === "7d") {
    const from = new Date(today);
    from.setDate(from.getDate() - 7);
    return { from: from.toISOString().split("T")[0], to };
  } else if (range === "30d") {
    const from = new Date(today);
    from.setDate(from.getDate() - 30);
    return { from: from.toISOString().split("T")[0], to };
  } else if (range === "90d") {
    const from = new Date(today);
    from.setDate(from.getDate() - 90);
    return { from: from.toISOString().split("T")[0], to };
  }
  return { to };
}

export default function AdminDashboardPage() {
  const [range, setRange] = useState<RangeKey>("7d");
  const [model, setModel] = useState<ModelKey>("all");
  const [tab, setTab] = useState<TabKey>("attempts");

  // API Data States
  const [summary, setSummary] = useState<any>(null);
  const [timeseries, setTimeseries] = useState<TimeseriesPoint[]>([]);
  const [topLessons, setTopLessons] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Fetch data when range changes
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError(null);
      try {
        const { from, to } = getDateRange(range);

        // Fetch all data in parallel
        const [summaryData, timeseriesData, topLessonsData] = await Promise.all([
          adminAnalyticsApi.getSummary(from, to),
          adminAnalyticsApi.getTimeseries(from, to),
          adminAnalyticsApi.getTopLessons("attempts", 5),
        ]);

        setSummary(summaryData);
        setTimeseries(timeseriesData.points || []);
        setTopLessons(
          topLessonsData.items?.map((item) => ({
            name: item.lessonId,
            completion: 0, // API doesn't provide completion %, use count as proxy
            ctr: item.count,
          })) || []
        );
      } catch (err: any) {
        console.error("Failed to fetch dashboard data:", err);
        setError(err.message || "Failed to load dashboard data");
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [range]);

  // Transform timeseries data for chart
  const trendData = useMemo(() => {
    return timeseries.map((point) => ({
      day: new Date(point.date).toLocaleDateString("en-US", { weekday: "short" }),
      attempts: point.attempts,
      completions: point.completions,
    }));
  }, [timeseries]);

  const latestPoint = trendData.length > 0 ? trendData[trendData.length - 1] : null;
  const previousPoint = trendData.length > 1 ? trendData[trendData.length - 2] : null;

  // Calculate changes
  const attemptsChange =
    latestPoint && previousPoint
      ? ((latestPoint.attempts - previousPoint.attempts) / previousPoint.attempts) * 100
      : 0;
  const completionsChange =
    latestPoint && previousPoint
      ? ((latestPoint.completions - previousPoint.completions) / previousPoint.completions) * 100
      : 0;

  // ----- PENDING FROM MOCK (keep for now, no API yet) -----
  const pendingVideos =
    pendingTasks.find((x) =>
      x.title.toLowerCase().includes("video")
    )?.value ?? 0;

  const unresolvedReports =
    pendingTasks.find((x) =>
      x.title.toLowerCase().includes("violation")
    )?.value ?? 0;

  const modelLabel =
    model === "gpt"
      ? "GPT only"
      : model === "claude"
        ? "Claude only"
        : model === "llama"
          ? "LLaMA only"
          : "All Models";

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Loading dashboard data...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-red-500">Error: {error}</div>
      </div>
    );
  }

  return (
    <div className="space-y-8 pb-10">
      {/* HEADER FILTERS */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <RangeFilter value={range} onChange={setRange} />

        <div className="flex items-center gap-3">
          <ModelFilter value={model} onChange={setModel} />
          <span className="hidden md:inline text-xs text-gray-500">
            {modelLabel}
          </span>
        </div>
      </div>

      {/* STATS ROW 1 - Learning Analytics */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <StatCard
          icon={Users}
          label="Total Users"
          value={summary?.usersTotal?.toLocaleString() || "0"}
        />

        <StatCard
          icon={Users}
          label="Active Learners (7d)"
          value={summary?.usersActive7d?.toLocaleString() || "0"}
        />

        <StatCard
          icon={ClipboardList}
          label="Total Attempts"
          value={summary?.attemptsTotal?.toLocaleString() || "0"}
        />

        <StatCard
          icon={Target}
          label="Avg Accuracy"
          value={
            summary?.avgAccuracyInRange
              ? `${(summary.avgAccuracyInRange * 100).toFixed(1)}%`
              : "0%"
          }
        />
      </div>

      {/* STATS ROW 2 - Range-specific stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <StatCard
          icon={ClipboardList}
          label={`Attempts (${range})`}
          value={summary?.attemptsInRange?.toLocaleString() || "0"}
          change={
            attemptsChange !== 0
              ? `${attemptsChange > 0 ? "+" : ""}${attemptsChange.toFixed(1)}%`
              : undefined
          }
          changeType={attemptsChange >= 0 ? "increase" : "decrease"}
        />

        <StatCard
          icon={Award}
          label={`Completions (${range})`}
          value={summary?.completionsInRange?.toLocaleString() || "0"}
          change={
            completionsChange !== 0
              ? `${completionsChange > 0 ? "+" : ""}${completionsChange.toFixed(1)}%`
              : undefined
          }
          changeType={completionsChange >= 0 ? "increase" : "decrease"}
        />

        <StatCard
          icon={PlayCircle}
          label="Pending Videos"
          value={`${pendingVideos}`}
        />

        <StatCard
          icon={AlertTriangle}
          label="Unresolved Reports"
          value={`${unresolvedReports}`}
        />
      </div>

      {/* CHARTS */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 auto-rows-fr">
        <TrendChartCard
          title="Learning Activity Trend"
          subtitle="Attempts and completions over time"
          data={trendData}
          tab={tab}
          onTabChange={setTab}
        />

        <DonutChartCard data={donutData} />
      </div>

      {/* LISTS */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 auto-rows-fr">
        <PendingTasks items={pendingTasks} />
        <TopLessons data={topLessons} />
        <NeedsAttention data={needsAttention} />
      </div>

      <RealtimeFeed data={realtimeFeed} />
    </div>
  );
}
