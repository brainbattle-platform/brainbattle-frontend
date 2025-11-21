export function LearnersHeader() {
  return (
    <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-3">
      

      {/* Right-side slot if you want global actions later */}
      <div className="text-xs text-gray-400 md:text-right md:ml-auto">
        Last updated just now
      </div>
    </div>
  );
}
