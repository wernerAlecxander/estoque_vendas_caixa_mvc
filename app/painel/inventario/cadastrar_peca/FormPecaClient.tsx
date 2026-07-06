// ./app/painel/inventario/cadastrar_peca/FormPecaClient.tsx
"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { cadastrarPecaDesmontadaAction } from "./actions";
import { InputMinimalista } from "@/components/InputMinimalista";
import { categoria_peca, localizacao_peca, setor_prateleira } from "@prisma/client";
import { PackagePlus, AlertCircle } from "lucide-react";

export function FormPecaClient({ sucatas, funcionarios }: any) {
  const [state, formAction, isPending] = useActionState(cadastrarPecaDesmontadaAction, null);
  const [sucataSelecionadaId, setSucataSelecionadaId] = useState("");
  const [modeloOrigemId, setModeloOrigemId] = useState("");
  const formRef = useRef<HTMLFormElement>(null);

  // Monitora a escolha do veículo de origem para vincular a compatibilidade do motor/modelo nativo
  useEffect(() => {
    const veiculo = sucatas.find((s: any) => s.id === sucataSelecionadaId);
    if (veiculo) {
      setModeloOrigemId(veiculo.modelo_id.toString());
    } else {
      setModeloOrigemId("");
    }
  }, [sucataSelecionadaId, sucatas]);

  useEffect(() => {
    if (state?.success) {
      formRef.current?.reset();
      setSucataSelecionadaId("");
      alert("Peça registrada e catalogada com sucesso na vitrine!");
    }
  }, [state]);

  return (
    <form action={formAction} ref={formRef} className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 space-y-6 shadow-sm">
      {state?.serverError && (
        <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/20 text-red-500 border border-red-200 dark:border-red-900/50 flex items-center gap-3 text-xs font-semibold">
          <AlertCircle className="h-4 w-4" />
          <span>{state.serverError}</span>
        </div>
      )}

      {/* Input oculto repassado ao Prisma automaticamente */}
      <input type="hidden" name="modelo_origem_id" value={modeloOrigemId} />

      {/* Origem e Responsável */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Veículo Adquirido de Origem *</label>
          <select value={sucataSelecionadaId} onChange={(e) => setSucataSelecionadaId(e.target.value)} name="veiculo_origem_id" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] focus:ring-2 focus:ring-[#00E676]/20 transition-all" required>
            <option value="">Selecione o veículo no pátio</option>
            {sucatas.map((s: any) => (
              <option key={s.id} value={s.id}>{s.marca_veiculo} {s.modelos.nome_modelo} — Chassi: {s.chassi.substring(0, 8)}...</option>
            ))}
          </select>
        </div>

        <div className="space-y-1.5">
          <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Operador do Desmonte *</label>
          <select name="responsavel_compra_id" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" required>
            <option value="">Selecione o mecânico/estoquista</option>
            {funcionarios.map((f: any) => <option key={f.id} value={f.id}>{f.nome} ({f.cargo_usuario})</option>)}
          </select>
        </div>
      </div>

      {/* Dados da Peça */}
      <div className="border-t border-gray-100 dark:border-gray-800/60 pt-4 space-y-4">
        <h2 className="text-[11px] font-bold text-[#00E676] uppercase tracking-wider">Identificação do Componente</h2>
        
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="sm:col-span-2">
            <InputMinimalista label="Descrição Comercial da Peça *" name="nome_peca" placeholder="Ex: Motor Parcial 1.6 Flex, Alternador Bosch 90A" error={state?.error?.nome_peca?.[0]} required />
          </div>
          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Sistemas / Categoria *</label>
            <select name="categoria" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" required>
              <option value="">Selecione</option>
              {Object.values(categoria_peca).map((cat) => <option key={cat} value={cat}>{cat.replace(/_/g, " ")}</option>)}
            </select>
          </div>
        </div>

        {/* Localização e Armazenamento */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Estrutura Física *</label>
            <select name="localizacao_peca" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" required>
              {Object.values(localizacao_peca).map((loc) => <option key={loc} value={loc}>{loc.replace(/_/g, " ")}</option>)}
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Divisória / Prateleira *</label>
            <select name="setor_prateleira" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" required>
              {Object.values(setor_prateleira).map((set) => <option key={set} value={set}>{set.replace(/_/g, " ")}</option>)}
            </select>
          </div>

          <InputMinimalista label="Preço Sugerido p/ Internet (R$) *" name="preco" type="number" step="0.01" placeholder="0.00" error={state?.error?.preco?.[0]} required />
        </div>
      </div>

      <div className="pt-2 flex justify-end">
        <button type="submit" disabled={isPending} className="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] hover:bg-opacity-90 disabled:opacity-50 transition-all cursor-pointer">
          <PackagePlus className="h-4 w-4 text-[#00E676] dark:text-[#0B0F19]" />
          <span>{isPending ? "Alocando no Estoque..." : "Disponibilizar para Venda"}</span>
        </button>
      </div>
    </form>
  );
}
