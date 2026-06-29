// ./app/painel/caixa/cadastrar_despesas/page.tsx
"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { cadastrarDespesaAction } from "./actions";
import { InputMinimalista } from "@/components/InputMinimalista";
import { categoria_despesas } from "@prisma/client";
import { DollarSign, AlertCircle } from "lucide-react";

// Tipo simples para tipar o estado dos funcionários
interface Funcionario {
  id: string;
  nome: string;
}

export default function CadastrarDespesasPage() {
  const [state, formAction, isPending] = useActionState(cadastrarDespesaAction, null);
  const [funcionarios, setFuncionarios] = useState<Funcionario[]>([]);
  const formRef = useRef<HTMLFormElement>(null);

  // Busca os funcionários ativos do banco de dados ao montar a tela
  useEffect(() => {
    async function carregarFuncionarios() {
      try {
        const res = await fetch("/api/funcionarios");
        if (res.ok) {
          const dados = await res.json();
          setFuncionarios(dados);
        }
      } catch (error) {
        console.error("Erro ao carregar funcionários:", error);
      }
    }
    carregarFuncionarios();
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

        <InputMinimalista 
          label="Descrição do Gasto *" 
          name="descricao_despesa" 
          placeholder="Ex: Conta de Energia Elétrica — Pátio de Desmonte" 
          error={state?.error?.descricao_despesa?.[0]} 
          required 
        />

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {/* SELEÇÃO DE CATEGORIA */}
          <div className="space-y-1.5 w-full">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">
              Centro de Custo / Categoria *
            </label>
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
            {state?.error?.categoria_despesa && (
              <p className="text-[10px] text-red-500 font-semibold">{state.error.categoria_despesa?.[0]}</p>
            )}
          </div>

          {/* VALOR DA DESPESA */}
          <InputMinimalista 
            label="Valor do Lançamento (R$) *" 
            name="valor_despesa" 
            type="number" 
            step="0.01" 
            placeholder="0.00" 
            error={state?.error?.valor_despesa?.[0]} 
            required 
          />
        </div>

        {/* SELEÇÃO DO RESPONSÁVEL (Substituiu o input hidden antigo) */}
        <div className="space-y-1.5 w-full">
          <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">
            Responsável pela Compra *
          </label>
          <select 
            name="responsavel_compra_id" 
            className={`w-full px-4 py-3 text-xs font-medium rounded-xl border bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:ring-2 transition-all ${
              state?.error?.responsavel_compra_id 
                ? "border-red-500 focus:ring-red-500/20" 
                : "border-gray-200 dark:border-gray-800 focus:border-[#0091FF] focus:ring-[#0091FF]/20"
            }`}
            required
          >
            <option value="">Selecione o funcionário</option>
            {funcionarios.map((func) => (
              <option key={func.id} value={func.id}>
                {func.nome}
              </option>
            ))}
          </select>
          {state?.error?.responsavel_compra_id && (
            <p className="text-[10px] text-red-500 font-semibold">{state.error.responsavel_compra_id?.[0]}</p>
          )}
        </div>

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
