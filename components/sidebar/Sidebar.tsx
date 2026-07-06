// estoque_vendas_caixa/components/sidebar/Sidebar.tsx
"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { menuItems, MenuItem, SubMenuItem } from "./menuData";
import { ThemeToggle } from "../ThemeToggle";
import { ChevronDown, ChevronRight, LayoutDashboard, LogOut } from "lucide-react";
import { signOut } from "next-auth/react";

export function Sidebar() {
  const pathname = usePathname();
  const [openMenu, setOpenMenu] = useState<string | null>(null);

  const toggleAccordion = (title: string) => {
    setOpenMenu(openMenu === title ? null : title);
  };

  const getIconColor = (title: string) => {
    switch (title) {
      case "Vendas":
      case "Inventário":
        return "text-[#00E676]";
      case "Compras":
      case "Manutenção":
        return "text-[#FFD600]";
      case "Caixa":
      case "Relatórios":
      case "Cadastros":
      default:
        return "text-[#0091FF]";
    }
  };

  return (
    <aside className="w-64 h-screen fixed left-0 top-0 z-40 bg-white dark:bg-[#0B0F19] border-r border-gray-200 dark:border-gray-800/60 flex flex-col justify-between transition-colors duration-200">
      <div className="flex flex-col flex-1 overflow-y-auto px-4 pt-6">
        
        <div className="flex items-center gap-2 px-2 mb-8">
          <div className="h-3 w-3 rounded-full bg-[#0091FF] animate-pulse" />
          <span className="text-base font-black tracking-widest text-gray-900 dark:text-white uppercase">
            ECO<span className="text-[#00E676]">FERRO</span>
          </span>
          <span className="text-[9px] font-bold tracking-tight bg-gray-100 dark:bg-gray-800/80 px-2 py-0.5 rounded-full text-gray-500">
            v1.0
          </span>
        </div>

        <div className="mb-4">
          <Link
            href="/painel"
            className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold tracking-wide transition-all ${
              pathname === "/painel"
                ? "bg-gray-100 dark:bg-[#111827] text-[#0091FF]"
                : "text-gray-500 hover:bg-gray-50 dark:hover:bg-[#111827]/40 hover:text-gray-900 dark:hover:text-white"
            }`}
          >
            <LayoutDashboard className="h-4 w-4" />
            <span>Dashboard Principal</span>
          </Link>
        </div>

        <nav className="space-y-1.5 flex-1">
          {menuItems.map((menu: MenuItem) => {
            const Icon = menu.icon;
            const isCurrentMenuOpen = openMenu === menu.title;

            return (
              <div key={menu.title} className="rounded-xl overflow-hidden">
                <button
                  onClick={() => toggleAccordion(menu.title)}
                  className={`w-full flex items-center justify-between px-3 py-2.5 text-xs font-semibold tracking-wide transition-all ${
                    isCurrentMenuOpen
                      ? "bg-gray-50 dark:bg-[#111827]/50 text-gray-900 dark:text-white"
                      : "text-gray-500 hover:bg-gray-50 dark:hover:bg-[#111827]/30 hover:text-gray-900 dark:hover:text-white"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <Icon className={`h-4 w-4 ${getIconColor(menu.title)}`} />
                    <span>{menu.title}</span>
                  </div>
                  {isCurrentMenuOpen ? (
                    <ChevronDown className="h-3.5 w-3.5 opacity-60" />
                  ) : (
                    <ChevronRight className="h-3.5 w-3.5 opacity-60" />
                  )}
                </button>

                {isCurrentMenuOpen && (
                  <div className="bg-gray-50/50 dark:bg-[#111827]/20 pl-7 pr-2 py-1 space-y-1 border-l-2 border-gray-100 dark:border-gray-800 ml-5 my-1">
                    {menu.subItems.map((sub: SubMenuItem) => {
                      const isSubActive = pathname === sub.path;
                      return (
                        <Link
                          key={sub.path}
                          href={sub.path}
                          className={`block py-1.5 px-2 rounded-lg text-[11px] font-medium tracking-wide transition-all ${
                            isSubActive
                              ? "text-[#00E676] bg-[#00E676]/5 dark:bg-[#00E676]/10 font-semibold"
                              : "text-gray-400 dark:text-gray-500 hover:text-gray-900 dark:hover:text-white"
                          }`}
                        >
                          {sub.title}
                        </Link>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </nav>
      </div>

      <div className="p-4 border-t border-gray-200 dark:border-gray-800/60 space-y-3">
        <ThemeToggle />
        
        <button
          onClick={() => signOut({ callbackUrl: "/login" })}
          className="w-full flex items-center gap-3 px-4 py-2.5 rounded-xl text-xs font-semibold text-red-500 hover:bg-red-50 dark:hover:bg-red-950/20 transition-all"
        >
          <LogOut className="h-4 w-4" />
          <span>Sair do Sistema</span>
        </button>
      </div>
    </aside>
  );
}
