// ./app/painel/cadastros/consultar_clientes/page.tsx
import { prisma } from "@/lib/prisma";
import { deletarClienteAction } from "./actions";
import { Search, Trash2, User, Phone, Mail, ShieldAlert } from "lucide-react";
import { revalidatePath } from "next/cache";

export const dynamic = "force-dynamic";

interface PageProps {
  searchParams: Promise<{ query?: string }>;
}

export default async function ConsultarClientesPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const busca = params.query ?? "";

  // Busca os clientes aplicando filtro caso o usuário digite algo na barra de pesquisa
  const clientes = await prisma.clientes.findMany({
    where: busca
      ? {
          OR: [
            { nome_cliente: { contains: busca, mode: "insensitive" } },
            { cpf_cliente: { contains: busca, mode: "insensitive" } },
            { email_cliente: { contains: busca, mode: "insensitive" } },
          ],
        }
      : {},
    orderBy: { nome_cliente: "asc" },
  });

  // Action interna de formulário para processar a barra de pesquisa sem Client Component
  async function buscarAction(formData: FormData) {
    "use server";
    const q = formData.get("search") as string;
    revalidatePath(`/painel/cadastros/consultar_clientes?query=${q}`);
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase">
          Consultar Clientes
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Visualize, pesquise e remova registros da base cadastral de clientes do ferro velho.
        </p>
      </div>

      {/* Barra de Pesquisa Server-Driven */}
      <form action={buscarAction} className="max-w-md relative">
        <Search className="absolute left-4 top-3.5 h-4 w-4 text-gray-400" />
        <input
          type="text"
          name="search"
          placeholder="Buscar por nome, CPF ou e-mail..."
          defaultValue={busca}
          className="w-full pl-11 pr-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#0091FF] focus:ring-2 focus:ring-[#0091FF]/20 transition-all"
        />
      </form>

      {/* Grid/Tabela Minimalista Premium Dark */}
      <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-gray-100 dark:border-gray-800/60 bg-gray-50/50 dark:bg-[#0B0F19]/20 text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider">
                <th className="p-4">Cliente</th>
                <th className="p-4">Identificação</th>
                <th className="p-4">Contatos</th>
                <th className="p-4 text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="text-xs divide-y divide-gray-100 dark:divide-gray-800/40 font-medium">
              {clientes.length === 0 ? (
                <tr>
                  <td colSpan={4} className="p-8 text-center text-gray-400 font-medium">
                    Nenhum cliente encontrado com os critérios informados.
                  </td>
                </tr>
              ) : (
                clientes.map((cliente) => (
                  <tr key={cliente.id} className="hover:bg-gray-50/40 dark:hover:bg-[#111827]/40 transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="h-8 w-8 rounded-xl bg-gray-100 dark:bg-[#0B0F19] flex items-center justify-center text-gray-400">
                          <User className="h-4 w-4 text-[#0091FF]" />
                        </div>
                        <div>
                          <span className="font-bold text-gray-900 dark:text-white block">{cliente.nome_cliente}</span>
                          <span className="text-[10px] text-gray-400 block mt-0.5">{cliente.cidade_cliente} - {cliente.cep_cliente}</span>
                        </div>
                      </div>
                    </td>
                    <td className="p-4 text-gray-600 dark:text-gray-300">
                      <span className="block font-mono">{cliente.cpf_cliente}</span>
                    </td>
                    <td className="p-4 space-y-1">
                      <span className="flex items-center gap-1.5 text-gray-400 dark:text-gray-400">
                        <Mail className="h-3 w-3 text-gray-500" /> {cliente.email_cliente}
                      </span>
                      {cliente.telefone_cliente && (
                        <span className="flex items-center gap-1.5 text-gray-400 dark:text-gray-400">
                          <Phone className="h-3 w-3 text-gray-500" /> {cliente.telefone_cliente}
                        </span>
                      )}
                    </td>
                    <td className="p-4 text-right">
                      <form
                        action={async () => {
                          "use server";
                          const res = await deletarClienteAction(cliente.id);
                          if (res?.error) {
                            // Captura e exibe erros lógicos através de logs nativos/alertas customizados
                            console.error(res.error);
                          }
                        }}
                      >
                        <button
                          type="submit"
                          className="p-2.5 rounded-xl border border-gray-100 dark:border-gray-800 text-red-500 hover:bg-red-50 dark:hover:bg-red-950/20 transition-all cursor-pointer inline-flex items-center"
                          title="Excluir Cliente"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </button>
                      </form>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
