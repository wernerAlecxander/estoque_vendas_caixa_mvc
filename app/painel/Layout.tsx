// ./app/painel/layout.tsx
import { Sidebar } from "@/components/sidebar/Sidebar";

export default function PainelLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex bg-gray-50 dark:bg-[#0B0F19] transition-colors duration-200">
      {/* Sidebar Fixo lateral */}
      <Sidebar />

      {/* Espaço de conteúdo dinâmico das subrotas */}
      <div className="flex-1 pl-64">
        <main className="max-w-7xl mx-auto p-6 md:p-8 min-h-screen">
          {children}
        </main>
      </div>
    </div>
  );
}
