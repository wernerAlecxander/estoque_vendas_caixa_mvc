// ./app/painel/compras/comprar/FormCompraClient.tsx
"use client";

import { useActionState, useEffect, useRef, useState } from "react";
import { realizarCompraAction } from "./actions";
import { InputMinimalista } from "@/components/InputMinimalista";
import { marca_veiculo, cor } from "@prisma/client";
import { ShoppingCart, AlertCircle } from "lucide-react";

export function FormCompraClient({ clientes, usuarios, modelos }: any) {
  const [state, formAction, isPending] = useActionState(realizarCompraAction, null);
  const [marcaSelecionada, setMarcaSelecionada] = useState("");
  const formRef = useRef<HTMLFormElement>(null);

  const modelosFiltrados = modelos.filter((m: any) => m.marca_veiculo === marcaSelecionada);

  useEffect(() => {
    if (state?.success) {
      formRef.current?.reset();
      setMarcaSelecionada("");
      alert("Compra e entrada de estoque efetuadas com sucesso!");
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

      {/* Seção 1: Atores da Negociação */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="space-y-1.5">
          <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Fornecedor / Vendedor *</label>
          <select name="cliente_vendedor_id" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#FFD600] focus:ring-2 focus:ring-[#FFD600]/20 transition-all" required>
            <option value="">Selecione o vendedor</option>
            {clientes.map((c: any) => <option key={c.id} value={c.id}>{c.nome_cliente} ({c.cpf_cliente})</option>)}
          </select>
        </div>

        <div className="space-y-1.5">
          <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Comprador (Funcionário) *</label>
          <select name="responsavel_compra_id" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#FFD600] focus:ring-2 focus:ring-[#FFD600]/20 transition-all" required>
            <option value="">Selecione o responsável</option>
            {usuarios.map((u: any) => <option key={u.id} value={u.id}>{u.nome} ({u.cargo_usuario})</option>)}
          </select>
        </div>
      </div>

      {/* Seção 2: Dados do Veículo */}
      <div className="border-t border-gray-100 dark:border-gray-800/60 pt-4 space-y-4">
        <h2 className="text-[11px] font-bold text-[#FFD600] uppercase tracking-wider">Características Técnicas da Sucata</h2>
        
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Fabricante *</label>
            <select value={marcaSelecionada} onChange={(e) => setMarcaSelecionada(e.target.value)} name="marca_veiculo" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#FFD600] transition-all" required>
              <option value="">Selecione</option>
              {Object.values(marca_veiculo).map((m) => <option key={m} value={m}>{m}</option>)}
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Modelo *</label>
            <select name="modelo_id" disabled={!marcaSelecionada} className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#FFD600] transition-all disabled:opacity-40" required>
              <option value="">Selecione a marca primeiro</option>
              {modelosFiltrados.map((mod: any) => <option key={mod.id} value={mod.id}>{mod.nome_modelo}</option>)}
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">Cor Predominante</label>
            <select name="cor" className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#FFD600] transition-all" required>
              {Object.values(cor).map((c) => <option key={c} value={c}>{c}</option>)}
            </select>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <InputMinimalista label="Número do Chassi *" name="chassi" placeholder="Digite os caracteres" error={state?.error?.chassi} required />
          <InputMinimalista label="Ano Fabricação *" name="ano_fabricacao" type="number" placeholder="Ex: 2012" error={state?.error?.ano_fabricacao} required />
          <InputMinimalista label="Ano Modelo *" name="ano_modelo" type="number" placeholder="Ex: 2013" error={state?.error?.ano_modelo} required />
        </div>
      </div>

      {/* Seção 3: Valores Financeiros */}
      <div className="border-t border-gray-100 dark:border-gray-800/60 pt-4">
        <div className="max-w-xs">
          <InputMinimalista label="Custo total de Aquisição (R$) *" name="valor_compra" type="number" step="0.01" placeholder="0.00" error={state?.error?.valor_compra} required />
        </div>
      </div>

      <div className="pt-2 flex justify-end">
        <button type="submit" disabled={isPending} className="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] hover:bg-opacity-90 disabled:opacity-50 transition-all cursor-pointer">
          <ShoppingCart className="h-4 w-4 text-[#FFD600] dark:text-[#0B0F19]" />
          <span>{isPending ? "Processando..." : "Efetivar Compra"}</span>
        </button>
      </div>
    </form>
  );
}
