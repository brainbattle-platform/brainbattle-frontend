export function UnitsHeader() {
  return (
    <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-3">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Learning Units</h1>
        <p className="text-sm text-gray-500 mt-1">Manage learning units and lessons</p>
      </div>
      <div className="text-xs text-gray-400 md:text-right md:ml-auto">
        Last updated just now
      </div>
    </div>
  );
}

