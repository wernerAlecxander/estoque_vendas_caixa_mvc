// estoque_vendas_caixa/components/ThemeToggle.tsx
"use client";

import { useTheme } from "next-themes";
import { Sun, Moon } from "lucide-react";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
      className="flex items-center justify-between w-full px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-800/80 bg-gray-100/50 dark:bg-[#111827]/40 hover:bg-gray-200 dark:hover:bg-[#111827]/80 text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-all duration-200"
      aria-label="Alternar Tema"
    >
      <div className="flex items-center gap-3">
        {theme === "dark" ? (
          <>
            <Sun className="h-4 w-4 text-[#FFD600]" />
            <span className="text-xs font-semibold tracking-wide">Padrão do Sistema</span>
          </>
        ) : (
          <>
            <Moon className="h-4 w-4 text-[#0091FF]" />
            <span className="text-xs font-semibold tracking-wide">Modo Escuro Premium</span>
          </>
        )}
      </div>
    </button>
  );
}


/*
"use client";

import { useTheme } from "next-themes";
import { Sun, Moon } from "lucide-react";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
      className="flex items-center justify-between w-full px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-800/80 bg-gray-100/50 dark:bg-[#111827]/40 hover:bg-gray-200 dark:hover:bg-[#111827]/80 text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-all duration-200"
      aria-label="Alternar Tema"
    >
      <div className="flex items-center gap-3">
        {theme === "dark" ? (
          <>
            <Sun className="h-4 w-4 text-[#FFD600]" />
            <span className="text-xs font-semibold tracking-wide">Padrão do Sistema</span>
          </>
        ) : (
          <>
            <Moon className="h-4 w-4 text-[#0091FF]" />
            <span className="text-xs font-semibold tracking-wide">Modo Escuro Premium</span>
          </>
        )}
      </div>
    </button>
  );
}
*/