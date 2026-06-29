// ./app/layout.tsx
import "@/app/globals.css";
import { Providers } from "@/components/Providers";

export const metadata = {
  title: "Ferro Velho PRO | Gestão Integrada",
  description: "Sistema de Controle de Estoque, Caixa e Indicadores Econômicos",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" suppressHydrationWarning>
      <body className="antialiased bg-gray-50 dark:bg-[#0B0F19] text-gray-900 dark:text-gray-100 transition-colors duration-200">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
