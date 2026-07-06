// ./app/painel/cadastros/cliente/page.tsx
"use client";

import { useActionState, useEffect, useRef } from "react";
import { cadastrarClienteAction } from "./actions";
import { InputMinimalista } from "@/components/InputMinimalista";
import { UserPlus, CheckCircle, AlertCircle } from "lucide-react";

export default function CadastrarClientePage() {
  const [state, formAction, isPending] = useActionState(cadastrarClienteAction, null);
  const formRef = useRef<HTMLFormElement>(null);

  useEffect(() => {
    if (state?.success) {
      formRef.current?.reset();
      alert("Cliente cadastrado com sucesso!");
    }
  }, [state]);

  return (
    <div className="max-w-2xl space-y-6">
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase">
          Cadastrar Novo Cliente
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Insira as informações do cliente para controle de ordens de serviço e caixa.
        </p>
      </div>

      <form action={formAction} ref={formRef} className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 space-y-6 shadow-sm">
        {state?.serverError && (
          <div className="p-4 rounded-xl bg-red-50 dark:bg-red-950/20 text-red-500 border border-red-200 dark:border-red-900/50 flex items-center gap-3 text-xs font-semibold">
            <AlertCircle className="h-4 w-4" />
            <span>{state.serverError}</span>
          </div>
        )}

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <InputMinimalista label="Nome Completo *" name="nome_cliente" placeholder="Ex: João Silva" error={state?.error?.nome_cliente?.[0]} required />
          <InputMinimalista label="CPF / CNPJ *" name="cpf_cliente" placeholder="000.000.000-00" error={state?.error?.cpf_cliente?.[0]} required />
          <InputMinimalista label="E-mail corporativo *" name="email_cliente" type="email" placeholder="cliente@provedor.com" error={state?.error?.email_cliente?.[0]} required />
          <InputMinimalista label="Telefone de contato" name="telefone_cliente" placeholder="(95) 99999-0000" error={state?.error?.telefone_cliente?.[0]} />
        </div>

        <div className="border-t border-gray-100 dark:border-gray-800/60 pt-4 space-y-4">
          <h2 className="text-[11px] font-bold text-[#0091FF] uppercase tracking-wider">Endereço de Entrega/Faturamento</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <InputMinimalista label="Endereço (Rua, Número)" name="endereco_cliente" placeholder="Av. Principal, 123" />
            <InputMinimalista label="Bairro" name="bairro_cliente" placeholder="Centro" />
            <InputMinimalista label="CEP" name="cep_cliente" placeholder="69300-000" defaultValue="69.300-000" />
            <InputMinimalista label="Cidade" name="cidade_cliente" placeholder="Boa Vista" defaultValue="Boa Vista" />
          </div>
        </div>

        <div className="pt-4 flex justify-end">
          <button
            type="submit"
            disabled={isPending}
            className="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] hover:bg-opacity-90 disabled:opacity-50 transition-all cursor-pointer"
          >
            <UserPlus className="h-4 w-4" />
            <span>{isPending ? "Salvando..." : "Salvar Cliente"}</span>
          </button>
        </div>
      </form>
    </div>
  );
}
