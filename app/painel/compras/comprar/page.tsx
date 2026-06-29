// ./app/painel/compras/comprar/page.tsx
import { prisma } from "@/lib/prisma";
import { realizarCompraAction } from "./actions";
import { FormCompraClient } from "./FormCompraClient";

export const dynamic = "force-dynamic";

export default async function RealizarComprasPage() {
  // Coleta todas as entidades necessárias para alimentar os combos seletores
  const [clientes, usuarios, modelos] = await Promise.all([
    prisma.clientes.findMany({ orderBy: { nome_cliente: "asc" } }),
    prisma.usuarios.findMany({ where: { status_usuario: "ativo" }, orderBy: { nome: "asc" } }),
    prisma.modelos.findMany({ orderBy: { nome_modelo: "asc" } }),
  ]);

  return (
    <div className="max-w-3xl space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-[#FFD600]" />
          Registrar Entrada de Veículo / Sucata
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Dê entrada em veículos adquiridos para desmonte. O sistema gerará as despesas automáticas no fluxo de caixa.
        </p>
      </div>

      <FormCompraClient clientes={clientes} usuarios={usuarios} modelos={modelos} />
    </div>
  );
}
