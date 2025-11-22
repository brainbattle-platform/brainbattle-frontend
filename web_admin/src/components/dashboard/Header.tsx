"use client";

import Image from "next/image";
import { usePathname } from "next/navigation";
import { Download, UserPlus, ShieldAlert } from "lucide-react";

const pageInfo: Record<string, { title: string; description: string }> = {
  "/admin": {
    title: "Dashboard",
    description: "Monitor brand visibility & performance across AI models",
  },
  "/admin/users/learners": {
    title: "Learners",
    description: "Manage learner accounts and activity",
  },
  "/admin/users": {
    title: "User Management",
    description: "Control and manage system users",
  },
  "/admin/users/creators": {
    title: "Creators & Access Rights",
    description: "Manage creators and permission levels",
  },
   "/admin/users/violations": {
    title: "Violation Reports",
    description: "Review reports, moderate content, and apply penalties",
  },

};

export default function Header() {
  const pathname = usePathname();
  const current =
    pageInfo[pathname] || { title: "Unknown Page", description: "" };

  const isDashboard = pathname === "/admin";
  const isLearnerList = pathname === "/admin/users/learners";
  const isCreatorPage = pathname === "/admin/users/creators";
  const isViolationPage = pathname === "/admin/users/violations";

  return (
    <header
      className="
        w-full sticky top-0 z-40
        px-6 py-4 
        bg-white/80 backdrop-blur-xl
        border-b border-gray-100
        flex items-center justify-between
        text-gray-900
        shadow-[0_2px_8px_-3px_rgba(0,0,0,0.06)]
      "
      style={{
        WebkitBackdropFilter: "blur(14px)",
        backdropFilter: "blur(14px)",
      }}
    >

      <div className="min-w-0">
        <h1 className="text-[20px] md:text-[22px] font-semibold tracking-wide truncate">
          {current.title}
        </h1>

        {current.description && (
          <p
            className="
              text-[13px] mt-0.5 truncate font-medium
              bg-gradient-to-r from-rose-500 via-pink-500 to-purple-500 
              bg-clip-text text-transparent
            "
          >
            {current.description}
          </p>
        )}
      </div>

      {isDashboard && (
        <div className="flex items-center gap-3">
          <button
            type="button"
            className="
              px-4 py-2 rounded-full text-sm font-medium
              bg-rose-100 text-rose-600 
              border border-rose-200 
              hover:bg-rose-200 transition
            "
          >
            Live Data
          </button>

          <button
            type="button"
            className="
              inline-flex items-center gap-2 text-sm font-semibold
              px-4 py-2 rounded-xl
              bg-gradient-to-r from-rose-400 via-pink-500 to-purple-500
              text-white shadow-sm
              hover:opacity-90 transition
            "
          >
            <Download className="w-4 h-4" />
            Export Report
          </button>
        </div>
      )}


      {isLearnerList && (
        <button
          type="button"
          className="
    inline-flex items-center gap-2 text-sm font-semibold
    px-4 py-2 rounded-xl
    bg-gradient-to-r from-white via-pink-50 to-white
    text-gray-800
    border border-pink-200 shadow-sm
    hover:bg-pink-50 hover:border-pink-300
    active:opacity-80
    transition
  "
        >
          <Download className="w-4 h-4 text-pink-500" />
          Export CSV
        </button>

      )}

      {isCreatorPage && (
        <div className="flex items-center gap-3">

          {/* Soft gradient button */}
          <button
            type="button"
            className="
        inline-flex items-center gap-2 text-sm font-semibold
        px-4 py-2 rounded-xl
        bg-gradient-to-r from-white via-pink-50 to-white
        text-gray-800
        border border-pink-200 shadow-sm
        hover:bg-pink-50 hover:border-pink-300
        active:opacity-80 transition
      "
          >
            <UserPlus className="w-4 h-4 text-pink-500" />
            Review pending
          </button>

          
        </div>
      )}

       {isViolationPage && (
        <div className="flex items-center gap-3">
          {/* Primary action */}
          <button
            type="button"
            className="
              inline-flex items-center gap-2 text-sm font-semibold
              px-4 py-2 rounded-xl
              bg-gradient-to-r from-rose-400 via-pink-500 to-purple-500
              text-white shadow-sm
              hover:opacity-90 transition
            "
          >
            <ShieldAlert className="w-4 h-4" />
            Moderation queue
          </button>

          {/* Secondary action */}
          <button
            type="button"
            className="
              inline-flex items-center gap-2 text-sm font-semibold
              px-4 py-2 rounded-xl
              bg-gradient-to-r from-white via-pink-50 to-white
              text-gray-800
              border border-pink-200 shadow-sm
              hover:bg-pink-50 hover:border-pink-300
              active:opacity-80 transition
            "
          >
            <Download className="w-4 h-4 text-pink-500" />
            Export CSV
          </button>
        </div>
      )}

      {!isDashboard && !isLearnerList && !isCreatorPage && !isViolationPage && (
        <div className="relative w-10 h-10 opacity-90">
          <Image
            src="/images/brainbattle_logo_really_pink.png"
            alt="BrainBattle Logo"
            fill
            className="object-contain"
          />
        </div>
      )}
    </header>
  );
}
