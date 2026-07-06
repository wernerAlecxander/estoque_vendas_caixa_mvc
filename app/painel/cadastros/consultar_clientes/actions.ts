// ./app/painel/cadastros/consultar_clientes/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { revalidatePath } from "next/cache";

export async function deletarClienteAction(id: string) {
  try {
    // Verifica se existem dependências ativas no banco para não violar integridade referencial
    const temVeiculos = await prisma.veiculos_cliente_manutencao.findFirst({
      where: { cliente_id: id }
    });

    if (temVeiculos) {
      return { error: "Não é possível deletar este cliente pois ele possui veículos vinculados." };
    }

    await prisma.clientes.delete({
      where: { id },
    });

    revalidatePath("/painel/cadastros/consultar_clientes");
    return { success: true };
  } catch (error) {
    return { error: "Erro interno ao tentar remover o cliente." };
  }
}
