// ./app/painel/vendas/pecas-avulsas/page.tsx
import { prisma } from "@/lib/prisma";
import { FormVendaClient } from "./FormVendaClient";
import { status_item } from "@prisma/client";

export const dynamic = "force-dynamic";

export default async function VendaPecasAvulsasPage() {
  // Carrega apenas os dados cruciais para a venda direta em balcão
  const [clientes, vendedores, pecasDisponiveis] = await Promise.all([
    prisma.clientes.findMany({ orderBy: { nome_cliente: "asc" } }),
    prisma.usuarios.findMany({ where: { status_usuario: "ativo" }, orderBy: { nome: "asc" } }),
    prisma.peca_estoque.findMany({
      where: { status_peca: status_item.Disponivel },
      include: { modelos: true },
      orderBy: { nome_peca: "asc" },
    }),
  ]);

  return (
    <div className="max-w-3xl space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-[#00E676]" />
          Terminal PDV — Venda de Peças Avulsas
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Selecione a peça alocada nas prateleiras para faturamento e emissão imediata de baixa contábil.
        </p>
      </div>

      <FormVendaClient clientes={clientes} vendedores={vendedores} pecas={pecasDisponiveis} />
    </div>
  );
}
