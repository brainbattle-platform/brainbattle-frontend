import type { CreatorRow } from "@/types/creators.types";

export function CreatorSpotlightGrid({ creators }: { creators: CreatorRow[] }) {
  const top = [...creators]
    .sort((a, b) => b.totalRevenueUsd - a.totalRevenueUsd)
    .slice(0, 3);

  // fill placeholders if < 3
  const filled = [...top];
  while (filled.length < 3) {
    filled.push({
      id: `placeholder-${filled.length}`,
      name: "—",
      username: "—",
      email: "—",
      status: "pending",
      accessLevel: "basic",
      kycVerified: false,
      country: "—",
      timezone: "—",
      language: "—",
      courses: 0,
      students: 0,
      followers: 0,
      avgRating: 0,
      totalRevenueUsd: 0,
      createdAt: new Date().toISOString(),
    } as CreatorRow);
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
      {filled.map((c) => {
        const isPlaceholder = c.id.startsWith("placeholder");
        return (
          <div
            key={c.id}
            className="
              rounded-2xl bg-white border border-gray-200 shadow-sm p-4
              flex items-center gap-3
            "
          >
            <div className="w-12 h-12 rounded-full overflow-hidden bg-gradient-to-r from-pink-400 to-purple-400 shrink-0">
              {!isPlaceholder && c.avatarUrl ? (
                <img
                  src={c.avatarUrl}
                  alt={c.name}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-white font-bold">
                  {isPlaceholder ? "?" : c.name.charAt(0)}
                </div>
              )}
            </div>

            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2">
                <div className={`font-semibold truncate ${isPlaceholder ? "text-gray-400" : "text-gray-900"}`}>
                  {isPlaceholder ? "Top creator slot" : c.name}
                </div>
                {!isPlaceholder && (
                  <div className="text-xs text-gray-500 truncate">@{c.username}</div>
                )}
              </div>

              <div className={`text-xs mt-0.5 ${isPlaceholder ? "text-gray-300" : "text-gray-500"}`}>
                {isPlaceholder
                  ? "Waiting for data"
                  : `${c.courses} courses • ${c.students.toLocaleString()} students`}
              </div>
            </div>

            <div className="text-right">
              <div className="text-xs text-gray-500">Revenue</div>
              <div className={`font-semibold ${isPlaceholder ? "text-gray-300" : "text-purple-700"}`}>
                {isPlaceholder ? "—" : `$${c.totalRevenueUsd.toLocaleString()}`}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
