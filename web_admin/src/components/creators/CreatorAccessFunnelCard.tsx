import type { CreatorRow } from "@/types/creators.types";

export function CreatorAccessFunnelCard({
  creators,
}: {
  creators: CreatorRow[];
}) {
  const applied = creators.length;
  const verified = creators.filter((c) => c.kycVerified).length;
  const active = creators.filter((c) => c.status === "active").length;
  const top = creators.filter((c) => c.accessLevel === "partner").length;

  const steps = [
    { label: "Applied", value: applied, tone: "bg-gray-200" },
    { label: "KYC", value: verified, tone: "bg-emerald-200" },
    { label: "Active", value: active, tone: "bg-pink-200" },
    { label: "Partners", value: top, tone: "bg-purple-200" },
  ];

  const max = Math.max(...steps.map((s) => s.value), 1);

  return (
    <div className="rounded-2xl bg-white border border-gray-200 shadow-sm p-4">
      <div className="mb-3">
        <h3 className="text-sm font-semibold text-gray-900">Access funnel</h3>
        <p className="text-xs text-gray-500">Application → partner</p>
      </div>

      {/* ✅ tighter to fit right-stack */}
      <div className="space-y-1.5">
        {steps.map((s) => (
          <div key={s.label} className="flex items-center gap-3">
            <div className="w-20 text-xs text-gray-600">{s.label}</div>
            <div className="flex-1 h-2 rounded-full bg-gray-100 overflow-hidden">
              <div
                className={`h-full ${s.tone}`}
                style={{ width: `${(s.value / max) * 100}%` }}
              />
            </div>
            <div className="w-8 text-right text-xs font-semibold text-gray-900">
              {s.value}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
