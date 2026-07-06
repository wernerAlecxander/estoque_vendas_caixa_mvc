// ./app/painel/cadastros/veiculos_clientes/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { marca_veiculo } from "@prisma/client";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const veiculoClienteSchema = z.object({
  cliente_id: z.uuid({ message: "Selecione um cliente válido" }),
  marca_veiculo: z.nativeEnum(marca_veiculo, { 
  error: "Selecione uma montadora válida" 
}),

  modelo_id: z.preprocess((val) => Number(val), z.number().positive("Selecione um modelo válido")),
});

export async function cadastrarVeiculoClienteAction(prevState: any, formData: FormData) {
  const dadosValidados = veiculoClienteSchema.safeParse({
    cliente_id: formData.get("cliente_id"),
    marca_veiculo: formData.get("marca_veiculo"),
    modelo_id: formData.get("modelo_id"),
  });

  if (!dadosValidados.success) {
    return { error: dadosValidados.error.flatten().fieldErrors };
  }

  try {
    await prisma.veiculos_cliente_manutencao.create({
      data: dadosValidados.data,
    });
    revalidatePath("/painel/cadastros/consultar_veiculos_clientes");
    return { success: true };
  } catch (error) {
    return { serverError: "Erro interno do servidor ao vincular veículo ao cliente." };
  }
}
