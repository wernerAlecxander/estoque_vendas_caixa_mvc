// ./app/painel/cadastros/modelos_veiculos/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { marca_veiculo } from "@prisma/client";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const modeloSchema = z.object({
  // CORRIGIDO: Passando a mensagem diretamente na propriedade 'error'
  marca_veiculo: z.nativeEnum(marca_veiculo, { error: "Selecione uma marca válida" }),
  nome_modelo: z.string().min(2, "Nome do modelo é muito curto"),
});

export async function cadastrarModeloAction(prevState: any, formData: FormData) {
  const dadosValidados = modeloSchema.safeParse({
    marca_veiculo: formData.get("marca_veiculo"),
    nome_modelo: formData.get("nome_modelo"),
  });

  if (!dadosValidados.success) {
    return { error: dadosValidados.error.flatten().fieldErrors };
  }

  try {
    await prisma.modelos.create({
      data: dadosValidados.data,
    });
    revalidatePath("/painel/cadastros/modelos_veiculos");
    return { success: true };
  } catch (error: any) {
    if (error.code === "P2002") {
      return { serverError: "Este modelo já está cadastrado para esta montadora." };
    }
    return { serverError: "Erro interno ao cadastrar modelo de veículo." };
  }
}
