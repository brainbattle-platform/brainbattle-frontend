"use client";

import { useMemo, useRef, useState, useEffect } from "react";
import { Search, Filter, ChevronDown, Download, UserPlus2, Check } from "lucide-react";
import type { CreatorStatus } from "@/types/creators.types";

type Opt = { label: string; value: CreatorStatus | "All" };
const OPTS: Opt[] = [
  { label: "All statuses", value: "All" },
  { label: "Active", value: "active" },
  { label: "Pending", value: "pending" },
  { label: "Suspended", value: "suspended" },
  { label: "Deleted", value: "deleted" },
];

function StatusFilter({
  value, onChange
}:{
  value: CreatorStatus | "All";
  onChange: (v: CreatorStatus | "All") => void;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement|null>(null);
  const current = useMemo(()=> OPTS.find(o=>o.value===value) ?? OPTS[0],[value]);

  useEffect(()=>{
    const close=(e:MouseEvent)=> ref.current && !ref.current.contains(e.target as Node) && setOpen(false);
    document.addEventListener("mousedown", close);
    return()=>document.removeEventListener("mousedown", close);
  },[]);

  return (
    <div ref={ref} className="relative">
      <button
        onClick={()=>setOpen(v=>!v)}
        className="
          inline-flex items-center gap-2 px-3 py-2 rounded-xl text-sm font-medium
          bg-white border border-gray-200 shadow-sm
          hover:border-pink-300 hover:shadow transition
          focus:outline-none focus:ring-2 focus:ring-pink-400/40
        "
      >
        <Filter className="w-4 h-4 text-gray-400" />
        <span className="text-gray-800">{current.label}</span>
        <ChevronDown className="w-4 h-4 text-gray-400" />
      </button>

      {open && (
        <div className="absolute right-0 mt-2 w-44 z-20 overflow-hidden rounded-2xl bg-white border border-gray-200 shadow-lg">
          {OPTS.map(opt=>{
            const active = opt.value===value;
            return (
              <button key={opt.value}
                onClick={()=>{ onChange(opt.value); setOpen(false); }}
                className={`w-full px-3 py-2.5 text-left text-sm flex items-center justify-between
                  ${active ? "bg-pink-50 text-pink-700" : "text-gray-700 hover:bg-gray-50"}`}
              >
                <span>{opt.label}</span>
                {active && <Check className="w-4 h-4" />}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

export function CreatorsToolbar({
  q, setQ, status, setStatus, onAdd, onExport
}:{
  q: string;
  setQ: (v:string)=>void;
  status: CreatorStatus | "All";
  setStatus: (v: CreatorStatus | "All")=>void;
  onAdd: ()=>void;
  onExport: ()=>void;
}) {
  return (
    <div className="rounded-2xl p-4 bg-white border border-gray-200 shadow-sm">
      <div className="flex flex-col lg:flex-row lg:items-center gap-3 justify-between">
        <div className="relative flex-1">
          <Search className="w-4 h-4 text-gray-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            value={q}
            onChange={(e)=>setQ(e.target.value)}
            placeholder="Search by name, username, email or UUID…"
            className="
              w-full h-11 pl-9 pr-3 rounded-xl text-sm
              bg-gray-50 border border-gray-200
              text-gray-900 placeholder:text-gray-400
              focus:outline-none focus:ring-2 focus:ring-pink-400/40 focus:border-pink-300
              transition
            "
          />
        </div>

        <div className="flex flex-wrap items-center gap-2">
          <StatusFilter value={status} onChange={setStatus} />

          <button
            onClick={onExport}
            className="
              inline-flex items-center gap-2 h-11 px-3 rounded-xl text-sm font-medium
              bg-gray-100 text-gray-700 hover:bg-gray-200 transition
            "
          >
            <Download className="w-4 h-4" /> Export CSV
          </button>

          <button
            onClick={onAdd}
            className="
              inline-flex items-center gap-2 h-11 px-4 rounded-xl text-sm font-semibold text-white
              bg-gradient-to-r from-pink-500 to-purple-500
              shadow-sm hover:opacity-95 transition
            "
          >
            <UserPlus2 className="w-4 h-4" /> Invite creator
          </button>
        </div>
      </div>
    </div>
  );
}
