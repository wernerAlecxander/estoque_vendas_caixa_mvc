// ./app/painel/cadastros/modelos_veiculos/page.tsx
"use client";

import { useActionState, useEffect, useRef } from "react";
import { cadastrarModeloAction } from "./actions";
import { InputMinimalista } from "@/components/InputMinimalista";
import { marca_veiculo } from "@prisma/client";
import { Car, AlertCircle } from "lucide-react";

export default function CadastrarModeloPage() {
  const [state, formAction, isPending] = useActionState(cadastrarModeloAction, null);
  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    if (state?.success) {
      formRef.current?.reset();
      alert("Modelo cadastrado com sucesso!");
    }
  }, [state]);

  return (
    <div className="max-w-xl space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase">
          Cadastrar Modelos de Veículos
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Adicione modelos vinculados às marcas do sistema para catalogar compatibilidade de peças.
        </p>
      </div>

      <form action={formAction} ref={formRef} className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 space-y-5 shadow-sm">
        {state?.serverError && (
          <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/20 text-red-500 border border-red-200 dark:border-red-900/50 flex items-center gap-3 text-xs font-semibold">
            <AlertCircle className="h-4 w-4" />
            <span>{state.serverError}</span>
          </div>
        )}

        <div className="space-y-1.5">
          <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">
            Montadora / Marca *
          </label>
          <select
            name="marca_veiculo"
            className="w-full px-4 py-3 text-xs font-medium rounded-xl border border-gray-200 dark:border-gray-800 bg-white dark:bg-[#111827] text-gray-900 dark:text-white focus:outline-none focus:border-[#0091FF] focus:ring-2 focus:ring-[#0091FF]/20 transition-all"
            required
          >
            <option value="">Selecione uma montadora</option>
            {Object.values(marca_veiculo).map((marca) => (
              <option key={marca} value={marca}>{marca}</option>
            ))}
          </select>
          {state?.error?.marca_veiculo && (
            <p className="text-[10px] text-red-500 font-semibold">{state.error.marca_veiculo[0]}</p>
          )}
        </div>

        <InputMinimalista label="Nome do Modelo *" name="nome_modelo" placeholder="Ex: Celta 1.0 MPFI" error={state?.error?.nome_modelo?.[0]} required />

        <div className="pt-2 flex justify-end">
          <button
            type="submit"
            disabled={isPending}
            className="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] hover:bg-opacity-90 disabled:opacity-50 transition-all cursor-pointer"
          >
            <Car className="h-4 w-4" />
            <span>{isPending ? "Salvando..." : "Salvar Modelo"}</span>
          </button>
        </div>
      </form>
    </div>
  );
}
