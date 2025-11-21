"use client";

import { useMemo, useState } from "react";

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
  trendBrand,
  trendMentions,
  donutData,
  pendingTasks,
  topLessons,
  needsAttention,
  realtimeFeed,
} from "@/mock/dashboard.mock";

type TabKey = "brand" | "mentions";

const getLast = (arr: any[]) =>
  Array.isArray(arr) && arr.length > 0 ? arr[arr.length - 1] : null;

export default function AdminDashboardPage() {
  const [range, setRange] = useState<RangeKey>("7d");
  const [model, setModel] = useState<ModelKey>("all");
  const [tab, setTab] = useState<TabKey>("brand");

  const brandSeries = useMemo(() => trendBrand[range] ?? [], [range]);
  const mentionSeries = useMemo(() => trendMentions[range] ?? [], [range]);

  const trendData = tab === "brand" ? brandSeries : mentionSeries;

  const latestBrand = getLast(brandSeries);
  const latestMention = getLast(mentionSeries);

  const visibilityScore = latestBrand?.display?.toFixed(1) ?? "0.0";
  const presenceScore = latestBrand?.presence ?? 0;

  const totalMentions = mentionSeries.reduce(
    (sum, x) => sum + (x.mentions ?? 0),
    0
  );
  const latestMentions = latestMention?.mentions ?? 0;

  // ----- PENDING FROM MOCK -----
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

      {/* STATS ROW 1 */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <StatCard
          icon={Eye}
          label="Visibility Score"
          value={visibilityScore}
          change="+12.5%"
          changeType="increase"
        />

        <StatCard
          icon={Target}
          label="Presence Score"
          value={`${presenceScore}%`}
          change="+8.2%"
          changeType="increase"
        />

        <StatCard
          icon={Award}
          label="Average Ranking"
          value="2.3"
          change="-0.4"
          changeType="decrease"
        />

        <StatCard
          icon={MessageCircle}
          label={`Total Mentions (${range})`}
          value={totalMentions.toLocaleString()}
          change={`+${latestMentions}`}
          changeType="increase"
        />
      </div>

      {/* STATS ROW 2 */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6">
        <StatCard
          icon={Users}
          label="Active Learners (7d)"
          value="12,391"
          change="+5.3%"
          changeType="increase"
        />

        <StatCard
          icon={PlayCircle}
          label="Pending Videos"
          value={`${pendingVideos}`}
        />

        <StatCard
          icon={ClipboardList}
          label="New Lessons (30d)"
          value="24"
          change="+8.1%"
          changeType="increase"
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
          title="Performance Trend"
          subtitle="Visibility, presence, mentions and citations over time"
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
