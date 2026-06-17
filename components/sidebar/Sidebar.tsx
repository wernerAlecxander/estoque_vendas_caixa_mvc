'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { menuItems } from './menuData';
import { ChevronDown, ChevronRight, Menu, Sun, Moon, Home } from 'lucide-react';

export default function Sidebar() {
  const pathname = usePathname();
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [openMenus, setOpenMenus] = useState<Record<string, boolean>>({});
  const [isDarkMode, setIsDarkMode] = useState(false);

  // Inicializa o Dark Mode baseado na preferência do sistema ou localStorage
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark' || (!savedTheme && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      setIsDarkMode(true);
      document.documentElement.classList.add('dark');
    }
  }, []);

  // Alterna o Dark Mode
  const toggleDarkMode = () => {
    if (isDarkMode) {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    } else {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    }
    setIsDarkMode(!isDarkMode);
  };

  // Alterna a abertura dos submenus
  const toggleSubMenu = (title: string) => {
    if (isCollapsed) setIsCollapsed(false); // Expande a sidebar se o usuário clicar em um item estando colapsado
    setOpenMenus((prev) => ({ ...prev, [title]: !prev[title] }));
  };

  return (
    <aside 
      className={`fixed top-0 left-0 h-screen bg-slate-50 dark:bg-zinc-950 border-r border-slate-200 dark:border-zinc-800 flex flex-col justify-between transition-all duration-300 ease-in-out z-40
        ${isCollapsed ? 'w-20' : 'w-64'}
      `}
    >
      {/* HEADER DA SIDEBAR */}
      <div>
        <div className="p-4 flex items-center justify-between border-b border-slate-200 dark:border-zinc-800">
          {!isCollapsed && (
            <span className="font-sans font-bold text-lg tracking-wide text-slate-800 dark:text-zinc-100">
              ⚙️ Ferro Velho
            </span>
          )}
          <button 
            onClick={() => setIsCollapsed(!isCollapsed)}
            className="p-2 rounded-lg hover:bg-slate-200 dark:hover:bg-zinc-800 text-slate-600 dark:text-zinc-400 transition-colors"
            title={isCollapsed ? "Expandir" : "Colapsar"}
          >
            <Menu size={20} />
          </button>
        </div>

        {/* LINK VOLTAR PARA HOME COMPACTO */}
        <div className="p-2 border-b border-slate-200 dark:border-zinc-800">
          <Link 
            href="/"
            className={`flex items-center gap-3 p-2 rounded-lg text-sm font-medium transition-all duration-200
              ${pathname === '/' 
                ? 'bg-emerald-500 text-white shadow-sm' 
                : 'text-slate-600 dark:text-zinc-400 hover:bg-slate-200 dark:hover:bg-zinc-800'}
            `}
          >
            <Home size={20} className="shrink-0" />
            {!isCollapsed && <span>Página Inicial</span>}
          </Link>
        </div>

        {/* ITENS DO MENU */}
        <nav className="p-2 space-y-1 overflow-y-auto max-h-[calc(100vh-140px)]">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isOpen = openMenus[item.title];
            // Verifica se alguma subpágina deste menu está ativa para aplicar o indicador visual
            const isChildActive = item.subItems.some(sub => pathname === sub.path);

            return (
              <div key={item.title} className="space-y-1">
                <button
                  onClick={() => toggleSubMenu(item.title)}
                  className={`w-full flex items-center justify-between p-2.5 rounded-lg text-sm font-medium transition-all duration-200
                    ${isChildActive 
                      ? 'text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-950/30 font-semibold' 
                      : 'text-slate-700 dark:text-zinc-300 hover:bg-slate-200 dark:hover:bg-zinc-800'}
                  `}
                >
                  <div className="flex items-center gap-3">
                    <Icon size={20} className={`shrink-0 ${isChildActive ? 'text-emerald-500' : 'text-slate-500'}`} />
                    {!isCollapsed && <span>{item.title}</span>}
                  </div>
                  
                  {!isCollapsed && (
                    isOpen ? <ChevronDown size={16} /> : <ChevronRight size={16} />
                  )}
                </button>

                {/* SUBMENU EXPANSÍVEL COM ANIMAÇÃO */}
                {!isCollapsed && isOpen && (
                  <div className="pl-9 space-y-1 transition-all duration-200">
                    {item.subItems.map((sub) => {
                      const isActive = pathname === sub.path;
                      return (
                        <Link
                          key={sub.path}
                          href={sub.path}
                          className={`block p-2 rounded-md text-xs font-medium transition-all duration-150 relative
                            ${isActive 
                              ? 'text-emerald-600 dark:text-emerald-400 bg-slate-200 dark:bg-zinc-800 font-semibold' 
                              : 'text-slate-500 dark:text-zinc-400 hover:text-slate-800 dark:hover:text-zinc-200'}
                          `}
                        >
                          {/* Indicador visual de página selecionada */}
                          {isActive && (
                            <span className="absolute left-0 top-1/4 w-1 h-1/2 bg-emerald-500 rounded-full" />
                          )}
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

      {/* RODAPÉ: BOTÃO DE INTERRUPÇÃO CLARO/ESCURO */}
      <div className="p-4 border-t border-slate-200 dark:border-zinc-800 flex items-center justify-center">
        <button
          onClick={toggleDarkMode}
          className="w-full flex items-center justify-center gap-3 p-2 rounded-lg border border-slate-300 dark:border-zinc-700 hover:bg-slate-200 dark:hover:bg-zinc-800 text-slate-700 dark:text-zinc-300 transition-colors text-sm font-medium"
        >
          {isDarkMode ? (
            <>
              <Sun size={18} className="text-amber-500" />
              {!isCollapsed && <span>Modo Claro</span>}
            </>
          ) : (
            <>
              <Moon size={18} className="text-indigo-500" />
              {!isCollapsed && <span>Modo Escuro</span>}
            </>
          )}
        </button>
      </div>
    </aside>
  );
}
