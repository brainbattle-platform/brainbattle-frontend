"use client";

import React, { useEffect, useRef, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import gsap from "gsap";
import { ChevronRight, X, LogOut } from "lucide-react";
import { cn } from "@/lib/utils";

import { MenuItem, menu } from "./sidebar.menu";

export default function AdminSidebarHoverExpand() {
  const pathname = usePathname();
  const router = useRouter();

  const [openGroups, setOpenGroups] = useState<Record<string, boolean>>({});
  const [showLogout, setShowLogout] = useState(false);
  const [expanded, setExpanded] = useState(false);

  const containerRef = useRef<HTMLDivElement | null>(null);
  const modalRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    gsap.fromTo(
      containerRef.current,
      { x: -36, opacity: 0 },
      { x: 0, opacity: 1, duration: 0.4, ease: "power2.out" }
    );
  }, []);

  useEffect(() => {
    if (showLogout) {
      gsap.fromTo(
        modalRef.current,
        { opacity: 0, scale: 0.94 },
        { opacity: 1, scale: 1, duration: 0.22, ease: "power2.out" }
      );
    }
  }, [showLogout]);

  const isChildActive = (children: MenuItem[]) =>
    children.some((x) => x.href && pathname.startsWith(x.href));

  const toggleGroup = (label: string) => {
    setOpenGroups((prev) => ({ ...prev, [label]: !prev[label] }));
  };

  const logoutNow = () => {
    try {
      localStorage.removeItem("bb_demo_login");
    } catch {}
    setShowLogout(false);
    router.push("/sign-in");
  };

  const width = expanded ? "w-72" : "w-[68px]";

  return (
    <>
      <aside
        ref={containerRef}
        onMouseEnter={() => setExpanded(true)}
        onMouseLeave={() => setExpanded(false)}
        className={cn(
          "h-screen flex flex-col overflow-y-hidden",
          "bg-white/70 backdrop-blur-xl",
          "border-r border-pink-200/60 shadow-[0_4px_20px_-4px_rgba(255,105,180,0.15)]",
          width,
          "transition-all duration-200"
        )}
        style={{
          borderTopRightRadius: 26,
          borderBottomRightRadius: 26,
        }}
      >
        <div className="p-5 border-b border-pink-200/50">
          <div className="flex items-center gap-3">
            <div className="relative w-10 h-10">
              <Image
                src="/images/brainbattle_logo_really_pink.png"
                alt="BrainBattle Logo"
                fill
                className="object-contain"
              />
            </div>

            {expanded && (
              <div>
                <h1 className="text-[16px] font-semibold text-pink-600 tracking-wide">
                  BRAIN BATTLE
                </h1>
                <p className="text-[12px] text-pink-400 font-medium">
                  Learning Language System
                </p>
              </div>
            )}
          </div>
        </div>

        <nav className="flex-1 px-2 py-3 overflow-y-auto scrollbar-thin scrollbar-thumb-pink-200/60">
          {menu.map((item) => {
            const isGroup = !!item.children;
            const open =
              (isGroup && openGroups[item.label]) ||
              (isGroup && isChildActive(item.children!));
            const activeTop = !isGroup && pathname === item.href;


            if (isGroup) {
              return (
                <div key={item.label} className="relative group">
                  <button
                    onClick={() => expanded && toggleGroup(item.label)}
                    title={!expanded ? item.label : undefined}
                    className={cn(
                      "w-full flex items-center gap-3 rounded-xl transition",
                      expanded ? "px-3 py-2.5" : "px-2.5 py-2",
                      "text-pink-600 hover:bg-pink-50/70 hover:shadow-sm",
                      "ring-1 ring-transparent hover:ring-pink-200/60"
                    )}
                  >
                    <item.icon className="w-5 h-5 shrink-0" />

                    {expanded && (
                      <>
                        <span className="flex-1 text-left text-[13.5px] font-medium text-slate-700">
                          {item.label}
                        </span>

                        <ChevronRight
                          className={cn(
                            "w-4 h-4 text-pink-300 transition-transform",
                            open && "rotate-90"
                          )}
                        />
                      </>
                    )}
                  </button>

                  {expanded && open && (
                    <div className="pl-10 mt-1 space-y-1.5">
                      {item.children!.map((child: MenuItem) => {
                        const active = pathname === child.href;

                        return (
                          <Link
                            key={child.label}
                            href={child.href!}
                            className={cn(
                              "flex items-center gap-3 px-3 py-2.5 rounded-lg transition",
                              "hover:bg-pink-50 hover:ring-1 hover:ring-pink-200/60",
                              active &&
                                "bg-gradient-to-r from-pink-100 via-pink-50 to-purple-100 text-pink-700 font-semibold ring-1 ring-pink-300"
                            )}
                          >
                            <child.icon className="w-5 h-5 text-pink-400" />
                            <span className="text-[13px]">{child.label}</span>
                          </Link>
                        );
                      })}
                    </div>
                  )}

                  {!expanded && (
                    <div
                      className={cn(
                        "pointer-events-none absolute left-[72px] top-0 z-40 min-w-[220px]",
                        "opacity-0 translate-x-1 scale-[0.98]",
                        "group-hover:opacity-100 group-hover:translate-x-0 group-hover:scale-100",
                        "transition-all duration-150 origin-left"
                      )}
                    >
                      <div className="pointer-events-auto p-2 rounded-2xl bg-white/90 backdrop-blur-xl border border-pink-200/60 shadow-xl">
                        <div className="flex items-center gap-3 px-2 py-1.5">
                          <item.icon className="w-5 h-5 text-pink-500" />
                          <span className="text-[13.5px] font-semibold text-slate-700">
                            {item.label}
                          </span>
                        </div>

                        <div className="mt-1 space-y-1">
                          {item.children!.map((child: MenuItem) => {
                            const active = pathname === child.href;

                            return (
                              <Link
                                key={child.label}
                                href={child.href!}
                                className={cn(
                                  "flex items-center gap-3 px-3 py-2.5 rounded-lg transition",
                                  "hover:bg-pink-50",
                                  active &&
                                    "bg-gradient-to-r from-pink-100 via-pink-50 to-purple-100 text-pink-700 font-semibold ring-1 ring-pink-300"
                                )}
                              >
                                <child.icon className="w-5 h-5 text-pink-400" />
                                <span className="text-[13px]">{child.label}</span>
                              </Link>
                            );
                          })}
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              );
            }

            return (
              <div key={item.label} className="relative group">
                <Link
                  href={item.href!}
                  title={!expanded ? item.label : undefined}
                  className={cn(
                    "flex items-center gap-3 rounded-xl transition select-none",
                    expanded ? "px-3 py-2.5" : "px-2.5 py-2",
                    "hover:bg-pink-50 hover:shadow-sm hover:ring-1 hover:ring-pink-200/60",
                    activeTop &&
                      "bg-gradient-to-r from-pink-100 via-pink-50 to-purple-100 text-pink-700 font-semibold ring-1 ring-pink-300"
                  )}
                >
                  <item.icon className="w-5 h-5 text-pink-500" />

                  {expanded && (
                    <span className="text-[13.5px] font-medium text-slate-700">
                      {item.label}
                    </span>
                  )}
                </Link>

                {/* COLLAPSED TOOLTIP */}
                {!expanded && (
                  <div
                    className={cn(
                      "pointer-events-none absolute left-[72px] top-1/2 -translate-y-1/2 z-40",
                      "opacity-0 translate-x-1 scale-[0.98]",
                      "group-hover:opacity-100 group-hover:translate-x-0 group-hover:scale-100",
                      "transition-all duration-150 origin-left"
                    )}
                  >
                    <div className="pointer-events-auto px-3 py-1.5 rounded-xl bg-white/90 backdrop-blur-xl border border-pink-200/60 shadow-xl text-[13px] font-medium text-slate-700">
                      {item.label}
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </nav>

        {/* FOOTER */}
        <div className="p-2.5 border-t border-pink-200/60 bg-white/70 backdrop-blur-xl">
          <button
            onClick={() => setShowLogout(true)}
            className={cn(
              "w-full flex items-center justify-center gap-3 rounded-xl transition",
              expanded ? "px-3 py-2.5" : "px-2.5 py-2",
              "bg-pink-50 text-pink-600 hover:bg-pink-100 hover:ring-1 hover:ring-pink-200"
            )}
          >
            <LogOut className="w-5 h-5" />
            {expanded && <span className="font-medium">Log out</span>}
          </button>
        </div>
      </aside>

      {/* LOGOUT MODAL */}
      {showLogout && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/30"
            onClick={() => setShowLogout(false)}
          />

          <div
            ref={modalRef}
            className="relative w-[92%] max-w-sm rounded-2xl p-5 bg-white/95 border border-pink-200 shadow-2xl"
          >
            <button
              onClick={() => setShowLogout(false)}
              className="absolute right-3 top-3 p-1 hover:bg-pink-50 rounded-md"
            >
              <X className="w-4 h-4 text-pink-400" />
            </button>

            <h3 className="text-[18px] font-semibold mb-2 text-slate-800">
              Log out?
            </h3>

            <p className="text-slate-500 mb-4">
              Are you sure you want to log out of the system?
            </p>

            <div className="flex justify-end gap-2">
              <button
                onClick={() => setShowLogout(false)}
                className="px-3 py-2 rounded-lg bg-slate-100 hover:bg-slate-200"
              >
                Cancel
              </button>

              <button
                onClick={logoutNow}
                className="px-3 py-2 rounded-lg bg-gradient-to-r from-pink-500 to-purple-500 text-white hover:opacity-90"
              >
                Log out
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
