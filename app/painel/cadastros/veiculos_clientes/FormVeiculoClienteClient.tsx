// ./app/painel/cadastros/veiculos_clientes/FormVeiculoClienteClient.tsx
"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { cadastrarVeiculoClienteAction } from "./actions";
import { marca_veiculo } from "@prisma/client";
import { Car, AlertCircle } from "lucide-react";

interface ClienteItem {
  id: string;
  nome_cliente: string;
  cpf_cliente: string;
}

interface ModeloItem {
  id: number;
  marca_veiculo: marca_veiculo;
  nome_modelo: string;
}

interface FormProps {
  clientes: ClienteItem[];
  modelos: ModeloItem[];
}

export function FormVeiculoClienteClient({ clientes, modelos }: FormProps) {
  const [state, formAction, isPending] = useActionState(cadastrarVeiculoClienteAction, null);
  const [marcaSelecionada, setMarcaSelecionada] = useState<string>("");
  const formRef = useRef<HTMLFormElement>(null);

  // Filtra os modelos do banco dinamicamente no front-end com base no gatilho da marca
  const modelosFiltrados = modelos.filter((mod) => mod.marca_veiculo === marcaSelecionada);

  useEffect(() => {
    if (state?.success) {
      formRef.current?.reset();
      setMarcaSelecionada("");
      alert("Veículo vinculado com sucesso!");
    }
  }, [state]);

  return (
    <form action={formAction} ref={formRef} className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 space-y-5 shadow-sm">
      {state?.serverError && (
        <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/20 text-red-500 border border-red-200 dark:border-red-900/50 flex items-center gap-3 text-xs font-semibold">
          <AlertCircle className="h-4 w-4" />
          <span>{state.serverError}</span>
        </div>
      )}

      {/* Select Clientes */}
      <div className="space-y-1.5">
        <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Proprietário / Cliente *</label>
        <select
          name="cliente_id"
          className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#0091FF] focus:ring-2 focus:ring-[#0091FF]/20 transition-all"
          required
        >
          <option value="">Selecione o proprietário</option>
          {clientes.map((c) => (
            <option key={c.id} value={c.id}>{c.nome_cliente} ({c.cpf_cliente})</option>
          ))}
        </select>
        {state?.error?.cliente_id && <p className="text-[10px] text-red-500 font-semibold">{state.error.cliente_id}</p>}
      </div>

      {/* Select Marca */}
      <div className="space-y-1.5">
        <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Marca / Fabricante *</label>
        <select
          name="marca_veiculo"
          value={marcaSelecionada}
          onChange={(e) => setMarcaSelecionada(e.target.value)}
          className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#0091FF] focus:ring-2 focus:ring-[#0091FF]/20 transition-all"
          required
        >
          <option value="">Selecione a fabricante</option>
          {Object.values(marca_veiculo).map((marca) => (
            <option key={marca} value={marca}>{marca}</option>
          ))}
        </select>
        {state?.error?.marca_veiculo && <p className="text-[10px] text-red-500 font-semibold">{state.error.marca_veiculo}</p>}
      </div>

      {/* Select Modelo dependente da Marca */}
      <div className="space-y-1.5">
        <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Modelo do Carro *</label>
        <select
          name="modelo_id"
          disabled={!marcaSelecionada}
          className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#0091FF] focus:border-opacity-100 focus:ring-2 focus:ring-[#0091FF]/20 transition-all disabled:opacity-40"
          required
        >
          <option value="">{marcaSelecionada ? "Selecione o modelo" : "Selecione a fabricante primeiro"}</option>
          {modelosFiltrados.map((m) => (
            <option key={m.id} value={m.id}>{m.nome_modelo}</option>
          ))}
        </select>
        {state?.error?.modelo_id && <p className="text-[10px] text-red-500 font-semibold">{state.error.modelo_id}</p>}
      </div>

      <div className="pt-2 flex justify-end">
        <button
          type="submit"
          disabled={isPending}
          className="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] hover:bg-opacity-90 disabled:opacity-50 transition-all cursor-pointer"
        >
          <Car className="h-4 w-4" />
          <span>{isPending ? "Vinculando..." : "Salvar Veículo"}</span>
        </button>
      </div>
    </form>
  );
}
