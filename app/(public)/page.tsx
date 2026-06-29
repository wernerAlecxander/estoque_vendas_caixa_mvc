// ./app/(public)/page.tsx
import { prisma } from "@/lib/prisma";
import { Search, ShoppingBag } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function VitrinePublica() {
  const pecasCatalogo = await prisma.peca_estoque.findMany({
    where: { status_peca: "Disponivel" },
    include: {
      modelos: true,
      peca_imagens: {
        where: { principal: true },
        take: 1
      }
    },
    orderBy: { data_cadastro: "desc" },
    take: 16
  });

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-[#0B0F19] transition-colors duration-200">
      
      {/* Navbar Pública */}
      <header className="bg-white dark:bg-[#111827] border-b border-gray-200 dark:border-gray-800/80 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <span className="text-sm font-black tracking-widest text-gray-900 dark:text-white uppercase">
            AUTO<span className="text-[#0091FF]">PEÇAS</span> RECYCLE
          </span>
          <a
            href="/login"
            className="text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] px-4 py-2 rounded-xl transition-transform active:scale-95"
          >
            Acesso Restrito
          </a>
        </div>
      </header>

      {/* Hero Search Section */}
      <section className="max-w-4xl mx-auto px-4 pt-12 pb-8 text-center space-y-4">
        <h1 className="text-2xl md:text-3xl font-black tracking-tight text-gray-900 dark:text-white">
          Encontre peças originais com rastreabilidade legal
        </h1>
        <p className="text-xs text-gray-500 max-w-lg mx-auto leading-relaxed">
          Estoque integrado em tempo real com desmontagem mecânica credenciada.
        </p>

        {/* Input de Busca Minimalista */}
        <div className="max-w-md mx-auto relative mt-6">
          <Search className="absolute left-4 top-3.5 h-4 w-4 text-gray-400" />
          <input
            type="text"
            placeholder="Buscar por nome da peça ou modelo de veículo..."
            className="w-full pl-11 pr-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-[#0091FF] transition-all"
          />
        </div>
      </section>

      {/* Feed da Vitrine */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {pecasCatalogo.map((peca) => (
            <div
              key={peca.id}
              className="group bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl overflow-hidden shadow-sm hover:shadow-md dark:hover:border-gray-700 transition-all duration-200 flex flex-col justify-between"
            >
              {/* Box da Imagem */}
              <div className="h-44 w-full bg-gray-100 dark:bg-[#0B0F19] relative flex items-center justify-center">
                {peca.peca_imagens?.[0] ? (
                  <img
                    src={peca.peca_imagens[0].url_imagem}
                    alt={peca.nome_peca}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                  />
                ) : (
                  <ShoppingBag className="h-8 w-8 text-gray-400 opacity-40" />
                )}
                <div className="absolute top-3 left-3 bg-white/90 dark:bg-[#0B0F19]/90 backdrop-blur-md px-2 py-0.5 rounded-md text-[9px] font-bold text-gray-600 dark:text-gray-300 uppercase tracking-wide">
                  {peca.categoria.replace(/_/g, " ")}
                </div>
              </div>

              {/* Informações */}
              <div className="p-4 flex-1 flex flex-col justify-between space-y-3">
                <div>
                  <h2 className="text-xs font-bold text-gray-900 dark:text-white line-clamp-1">
                    {peca.nome_peca}
                  </h2>
                  <p className="text-[10px] text-gray-400 font-medium mt-0.5">
                    Compatibilidade: {peca.modelos.nome_modelo}
                  </p>
                </div>

                <div className="flex items-center justify-between pt-2 border-t border-gray-100 dark:border-gray-800/60">
                  <span className="text-sm font-black text-[#0091FF]">
                    R$ {Number(peca.preco).toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
                  </span>
                  <span className="text-[9px] font-bold text-[#00E676] bg-[#00E676]/10 px-2 py-0.5 rounded-full">
                    Disponível
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
