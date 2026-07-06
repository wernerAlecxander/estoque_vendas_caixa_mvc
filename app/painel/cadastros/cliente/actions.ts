// ./app/painel/cadastros/cliente/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const clienteSchema = z.object({
  nome_cliente: z.string().min(3, "O nome deve ter no mínimo 3 caracteres"),
  cpf_cliente: z.string().min(11, "CPF inválido").max(14, "CPF inválido"),
  email_cliente: z.string().email("E-mail inválido"),
  telefone_cliente: z.string().optional(),
  endereco_cliente: z.string().optional(),
  bairro_cliente: z.string().optional(),
  cep_cliente: z.string().default("69.300-000"),
  cidade_cliente: z.string().default("Boa Vista"),
});

export async function cadastrarClienteAction(prevState: any, formData: FormData) {
  const dadosValidados = clienteSchema.safeParse({
    nome_cliente: formData.get("nome_cliente"),
    cpf_cliente: formData.get("cpf_cliente"),
    email_cliente: formData.get("email_cliente"),
    telefone_cliente: formData.get("telefone_cliente"),
    endereco_cliente: formData.get("endereco_cliente"),
    bairro_cliente: formData.get("bairro_cliente"),
    cep_cliente: formData.get("cep_cliente") || "69.300-000",
    cidade_cliente: formData.get("cidade_cliente") || "Boa Vista",
  });

  if (!dadosValidados.success) {
    return { error: dadosValidados.error.flatten().fieldErrors };
  }

  try {
    await prisma.clientes.create({
      data: dadosValidados.data,
    });
    revalidatePath("/painel/cadastros/consultar_clientes");
    return { success: true };
  } catch (error: any) {
    if (error.code === "P2002") {
      return { serverError: "CPF ou E-mail já cadastrado no sistema." };
    }
    return { serverError: "Erro interno do servidor ao salvar cliente." };
  }
}
