// ./app/painel/caixa/cadastrar_despesas/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { categoria_despesas } from "@prisma/client";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const despesaSchema = z.object({
  descricao_despesa: z.string().min(5, "Dê uma descrição mais detalhada da despesa"),
  valor_despesa: z.preprocess((val) => Number(val), z.number().positive("Insira um valor válido")),
  responsavel_compra_id: z.uuid({ message: "Selecione o funcionário responsável" }),
  categoria_despesa: z.nativeEnum(categoria_despesas, { error: "Selecione uma categoria válida" }),
});

export async function cadastrarDespesaAction(prevState: any, formData: FormData) {
  const dadosValidados = despesaSchema.safeParse({
    descricao_despesa: formData.get("descricao_despesa"),
    valor_despesa: formData.get("valor_despesa"),
    responsavel_compra_id: formData.get("responsavel_compra_id"),
    categoria_despesa: formData.get("categoria_despesa"),
  });

  if (!dadosValidados.success) {
    return { error: dadosValidados.error.flatten().fieldErrors };
  }

  try {
    await prisma.despesas.create({
      data: dadosValidados.data,
    });
    revalidatePath("/painel");
    revalidatePath("/painel/caixa");
    return { success: true };
  } catch (error) {
    return { serverError: "Erro interno do servidor ao salvar a despesa." };
  }
}
