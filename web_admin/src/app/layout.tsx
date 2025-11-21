import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "@/styles/globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Brain Battle Management",
  description: "Brain Battle - Learning Language Management System",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="vi">
      <body className={inter.className}>
        {/* Root chỉ bọc nền chung, không dính admin shell */}
        <div className="min-h-screen bg-white text-gray-900">
          {children}
        </div>
      </body>
    </html>
  );
}
