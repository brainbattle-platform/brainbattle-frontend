
import Sidebar from "@/components/dashboard/Sidebar";
import Header from "@/components/dashboard/Header";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="h-screen flex overflow-hidden bg-[#F7F8FA] text-gray-900">
      <aside className="h-full shrink-0 sticky top-0 overflow-y-auto bg-[#F7F8FA]">
        <Sidebar />
      </aside>

      <div className="flex flex-col flex-1 min-w-0 h-full">
        <Header />
        <main className="flex-1 overflow-y-auto p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
