// ./app/painel/inventario/cadastrar_peca/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { categoria_peca, localizacao_peca, setor_prateleira, status_item } from "@prisma/client";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const pecaSchema = z.object({
  veiculo_origem_id: z.uuid({ message: "Selecione a sucata de origem" }),
  nome_peca: z.string().min(3, "O nome da peça deve ser mais descritivo"),
  modelo_origem_id: z.preprocess((val) => Number(val), z.number().positive("Modelo de origem inválido")),
  categoria: z.nativeEnum(categoria_peca, { error: "Selecione uma categoria" }),
  preco: z.preprocess((val) => Number(val), z.number().nonnegative("O preço não pode ser negativo")),
  localizacao_peca: z.nativeEnum(localizacao_peca, { error: "Selecione a localização" }),
  setor_prateleira: z.nativeEnum(setor_prateleira, { error: "Selecione o setor" }),
  responsavel_compra_id: z.uuid({ message: "Selecione o funcionário responsável" }),
});

export async function cadastrarPecaDesmontadaAction(prevState: any, formData: FormData) {
  const dadosValidados = pecaSchema.safeParse({
    veiculo_origem_id: formData.get("veiculo_origem_id"),
    nome_peca: formData.get("nome_peca"),
    modelo_origem_id: formData.get("modelo_origem_id"),
    categoria: formData.get("categoria"),
    preco: formData.get("preco"),
    localizacao_peca: formData.get("localizacao_peca"),
    setor_prateleira: formData.get("setor_prateleira"),
    responsavel_compra_id: formData.get("responsavel_compra_id"),
  });

  if (!dadosValidados.success) {
    return { error: dadosValidados.error.flatten().fieldErrors };
  }

  try {
    await prisma.peca_estoque.create({
      data: {
        ...dadosValidados.data,
        status_peca: status_item.Disponivel,
      },
    });

    revalidatePath("/painel");
    revalidatePath("/"); // Atualiza automaticamente a vitrine pública na internet
    return { success: true };
  } catch (error: any) {
    if (error.code === "P2002") {
      return { serverError: "Esta mesma peça já foi cadastrada para este veículo específico." };
    }
    return { serverError: "Erro interno ao salvar a peça no estoque." };
  }
}
