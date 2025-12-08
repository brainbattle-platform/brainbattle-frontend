'use client';

import { ReactNode, useEffect, useRef } from 'react';
import gsap from 'gsap';
import BrandPanel from '@/components/auth/BrandPanel';

export default function AuthLayout({ children }: { children: ReactNode }) {
  const pageRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    gsap.fromTo(pageRef.current, { opacity: 0 }, { opacity: 1, duration: 0.35, ease: 'power2.out' });
  }, []);

  return (
    <main ref={pageRef} className="flex w-screen min-h-screen bg-white">
      <section className="flex flex-col justify-center items-center w-full lg:w-1/2 px-4 sm:px-6 bg-white">
        <div className="w-full max-w-md">{children}</div>
      </section>

      <BrandPanel />
    </main>
  );
}
