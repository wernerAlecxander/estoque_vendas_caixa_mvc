// ./app/painel/caixa/cadastrar_despesas/page.tsx
"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { cadastrarDespesaAction } from "./actions";
import { InputMinimalista } from "@/components/InputMinimalista";
import { categoria_despesas } from "@prisma/client";
import { DollarSign, AlertCircle } from "lucide-react";

export default function CadastrarDespesasPage() {
  const [state, formAction, isPending] = useActionState(cadastrarDespesaAction, null);
  const [funcionarios, setFuncionarios] = useState<any[]>([]);
  const formRef = useRef<HTMLFormElement>(null);

  // Busca simples de funcionários ativos na montagem para popular o responsável
  useEffect(() => {
    async function carregarFuncionarios() {
      const res = await fetch("/api/funcionarios"); // Criação recomendada ou substitua por server data
      if (res.ok) setFuncionarios(await res.json());
    }
    // Para simplificar no Docker, você pode injetar via Server Component ou buscar direto via fetch
  }, []);

  useEffect(() => {
    if (state?.success) {
      formRef.current?.reset();
      alert("Despesa computada no fluxo de caixa!");
    }
  }, [state]);

  return (
    <div className="max-w-xl space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-amber-500" />
          Lançamento de Despesa Operacional
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Insira saídas financeiras fixas ou variáveis para ajuste imediato do Break-Even corporativo.
        </p>
      </div>

      <form action={formAction} ref={formRef} className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 space-y-5 shadow-sm">
        {state?.serverError && (
          <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/20 text-red-500 border border-red-200 dark:border-red-900/50 flex items-center gap-3 text-xs font-semibold">
            <AlertCircle className="h-4 w-4" />
            <span>{state.serverError}</span>
          </div>
        )}

        <InputMinimalista label="Descrição do Gasto *" name="descricao_despesa" placeholder="Ex: Conta de Energia Elétrica — Pátio de Desmonte" error={state?.error?.descricao_despesa} required />

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Centro de Custo / Categoria *</label>
            <select 
              name="categoria_despesa" 
              className={`w-full px-4 py-3 text-xs font-medium rounded-xl border bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:ring-2 transition-all ${
                state?.error?.categoria_despesa 
                  ? "border-red-500 focus:ring-red-500/20" 
                  : "border-gray-200 dark:border-gray-800 focus:border-[#0091FF] focus:ring-[#0091FF]/20"
              }`}
              required
            >
              <option value="">Selecione</option>
              {Object.values(categoria_despesas).map((cat) => (
                <option key={cat} value={cat}>{cat.replace(/_/g, " ")}</option>
              ))}
            </select>
          </div>

          <InputMinimalista label="Valor do Lançamento (R$) *" name="valor_despesa" type="number" step="0.01" placeholder="0.00" error={state?.error?.valor_despesa} required />
        </div>

        {/* Input temporário de id de funcionário padrão até a sincronização completa da sessão ou use o ID do admin gerado no seed: */}
        <input type="hidden" name="responsavel_compra_id" value="admin_id_ou_coletado_da_sessao" /> 
        {/* Dica: Você pode capturar dinamicamente usando req.auth no middleware ou via useSession no client */}

        <div className="pt-2 flex justify-end">
          <button type="submit" disabled={isPending} className="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] hover:bg-opacity-90 disabled:opacity-50 transition-all cursor-pointer">
            <DollarSign className="h-4 w-4 text-amber-500" />
            <span>{isPending ? "Processando..." : "Lançar Saída"}</span>
          </button>
        </div>
      </form>
    </div>
  );
}
