// ./app/painel/vendas/pecas-avulsas/FormVendaClient.tsx
"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { realizarVendaPecaAction } from "./actions";
import { metodo_pagamento } from "@prisma/client";
import { DollarSign, AlertCircle, ShoppingBag } from "lucide-react";

export function FormVendaClient({ clientes, vendedores, pecas }: any) {
  const [state, formAction, isPending] = useActionState(realizarVendaPecaAction, null);
  const [pecaSelecionadaId, setPecaSelecionadaId] = useState("");
  const [precoVisual, setPrecoVisual] = useState<number>(0);
  const formRef = useRef<HTMLFormElement>(null);

  // Atualiza o visor de preço do PDV dinamicamente ao selecionar o item
  useEffect(() => {
    const item = pecas.find((p: any) => p.id === pecaSelecionadaId);
    if (item) {
      setPrecoVisual(Number(item.preco));
    } else {
      setPrecoVisual(0);
    }
  }, [pecaSelecionadaId, pecas]);

  useEffect(() => {
    if (state?.success) {
      formRef.current?.reset();
      setPecaSelecionadaId("");
      alert("Venda faturada e homologada com sucesso!");
    }
  }, [state]);

  return (
    <form action={formAction} ref={formRef} className="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      {/* Coluna da Esquerda: Dados do Formulário */}
      <div className="lg:col-span-2 bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 space-y-5 shadow-sm">
        {state?.serverError && (
          <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/20 text-red-500 border border-red-200 dark:border-red-900/50 flex items-center gap-3 text-xs font-semibold">
            <AlertCircle className="h-4 w-4" />
            <span>{state.serverError}</span>
          </div>
        )}

        {/* Seleção do Produto / Peça */}
        <div className="space-y-1.5">
          <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Buscar Peça Disponível no Estoque *</label>
          <select
            value={pecaSelecionadaId}
            onChange={(e) => setPecaSelecionadaId(e.target.value)}
            name="peca_estoque_id"
            className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] focus:ring-2 focus:ring-[#00E676]/20 transition-all"
            required
          >
            <option value="">Selecione ou digite o nome da peça</option>
            {pecas.map((p: any) => (
              <option key={p.id} value={p.id}>
                {p.nome_peca} [{p.modelos.nome_modelo}] — Prateleira: {p.localizacao_peca.replace(/_/g, " ")}
              </option>
            ))}
          </select>
        </div>

        {/* Clientes e Vendedores */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Cliente Comprador *</label>
            <select name="cliente_comprador_id" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" required>
              <option value="">Selecione o comprador</option>
              {clientes.map((c: any) => <option key={c.id} value={c.id}>{c.nome_cliente} ({c.cpf_cliente})</option>)}
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Operador do Caixa *</label>
            <select name="responsavel_venda_id" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" required>
              <option value="">Selecione o vendedor</option>
              {vendedores.map((v: any) => <option key={v.id} value={v.id}>{v.nome} ({v.cargo_usuario})</option>)}
            </select>
          </div>
        </div>

        {/* Forma de Pagamento e Observações */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 border-t border-gray-100 dark:border-gray-800/60 pt-4">
          <div className="sm:col-span-1 space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Meio de Recebimento *</label>
            <select name="metodo_pagamento" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" required>
              {Object.values(metodo_pagamento).map((m) => <option key={m} value={m}>{m}</option>)}
            </select>
          </div>

          <div className="sm:col-span-2 space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Observações do Recibo (Opcional)</label>
            <input type="text" name="observacoes_recibo" placeholder="Ex: Garantia estendida da carcaça do motor" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#00E676] transition-all" />
          </div>
        </div>
      </div>

      {/* Coluna da Direita: Painel Visual PDV (Checkout) */}
      <div className="bg-[#111827] dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 flex flex-col justify-between text-white space-y-6">
        <div className="space-y-4">
          <div className="flex items-center gap-2 text-xs font-bold text-gray-400 uppercase tracking-wider">
            <ShoppingBag className="h-4 w-4 text-[#00E676]" />
            <span>Resumo do Faturamento</span>
          </div>

          <div className="bg-[#0B0F19] rounded-xl p-4 border border-gray-800">
            <span className="text-[10px] font-bold text-gray-500 block uppercase">Subtotal do Caixa</span>
            <span className="text-3xl font-black text-[#00E676] block mt-1 tracking-tight">
              R$ {precoVisual.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div className="text-[10px] text-gray-400 font-semibold space-y-1 bg-gray-900/30 p-3 rounded-xl border border-gray-800/40">
            <p className="flex justify-between"><span>Garantia de Balcão:</span> <span className="text-white font-mono">90 Dias (Legal)</span></p>
            <p className="flex justify-between"><span>Tributação Estimada:</span> <span className="text-white font-mono">Inclusa</span></p>
          </div>
        </div>

        <button
          type="submit"
          disabled={isPending || !pecaSelecionadaId}
          className="w-full flex items-center justify-center gap-2 py-4 rounded-xl text-xs font-bold tracking-wider uppercase bg-[#00E676] text-[#0B0F19] hover:bg-opacity-90 disabled:opacity-30 disabled:cursor-not-allowed transition-all shadow-lg shadow-[#00E676]/10 cursor-pointer"
        >
          <DollarSign className="h-4 w-4" />
          <span>{isPending ? "Concluindo Venda..." : "Confirmar e Lançar"}</span>
        </button>
      </div>

    </form>
  );
}
