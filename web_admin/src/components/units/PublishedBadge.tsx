export function PublishedBadge({ published }: { published: boolean }) {
  return (
    <span
      className={[
        "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium",
        published
          ? "bg-green-50 text-green-700 border border-green-200"
          : "bg-gray-50 text-gray-700 border border-gray-200",
      ].join(" ")}
    >
      {published ? "Published" : "Draft"}
    </span>
  );
}

