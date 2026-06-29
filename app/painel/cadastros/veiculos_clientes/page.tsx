// ./app/painel/cadastros/veiculos_clientes/page.tsx
import { prisma } from "@/lib/prisma";
import { cadastrarVeiculoClienteAction } from "./actions";
import { FormVeiculoClienteClient } from "./FormVeiculoClienteClient";

export const dynamic = "force-dynamic";

export default async function CadastrarVeiculosClientesPage() {
  // Busca concorrente das tabelas dependentes no banco de dados Postgres
  const [listaClientes, listaModelos] = await Promise.all([
    prisma.clientes.findMany({ orderBy: { nome_cliente: "asc" }, select: { id: true, nome_cliente: true, cpf_cliente: true } }),
    prisma.modelos.findMany({ orderBy: { nome_modelo: "asc" } }),
  ]);

  return (
    <div className="max-w-xl space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase">
          Cadastrar Veículo de Cliente
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Vincule um carro à conta de um cliente para abertura de orçamentos e histórico de serviços.
        </p>
      </div>

      {/* Repassa os dados puros do banco para o gerenciamento de estado do formulário */}
      <FormVeiculoClienteClient clientes={listaClientes} modelos={listaModelos} />
    </div>
  );
}
