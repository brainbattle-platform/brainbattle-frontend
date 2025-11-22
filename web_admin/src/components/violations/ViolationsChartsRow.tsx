import type { ViolationRow } from "@/types/violations.types";
import { ViolationTypeTrendCard } from "./ViolationTypeTrendCard";
import { ViolationStatusDonutCard } from "./ViolationStatusDonutCard";

export function ViolationsChartsRow({ items }: { items: ViolationRow[] }) {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-3 gap-3 items-stretch">
      <div className="lg:col-span-2 h-full">
        <ViolationTypeTrendCard className="h-full" />
      </div>

      <div className="h-full">
        <ViolationStatusDonutCard items={items} className="h-full" />
      </div>
    </div>
  );
}
