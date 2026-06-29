// ./app/painel/inventario/cadastrar_peca/page.tsx
import { prisma } from "@/lib/prisma";
import { FormPecaClient } from "./FormPecaClient";

export const dynamic = "force-dynamic";

export default async function CadastrarPecaPage() {
  // Coleta as sucatas que estão ativas no pátio aguardando ou executando desmonte
  const [sucatasDisponiveis, funcionarios] = await Promise.all([
    prisma.sucata_estoque.findMany({
      where: {
        status_sucata: { in: ["Em_desmonte", "Em_manuten__o"] },
      },
      include: { modelos: true },
      orderBy: { data_entrada: "desc" },
    }),
    prisma.usuarios.findMany({
      where: { status_usuario: "ativo" },
      orderBy: { nome: "asc" },
    }),
  ]);

  return (
    <div className="max-w-3xl space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-[#00E676]" />
          Triagem de Desmonte & Cadastro de Peça
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Selecione a sucata de origem para desmembrar componentes diretamente para as prateleiras de venda.
        </p>
      </div>

      <FormPecaClient sucatas={sucatasDisponiveis} funcionarios={funcionarios} />
    </div>
  );
}
