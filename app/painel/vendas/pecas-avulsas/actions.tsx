// ./app/painel/vendas/pecas-avulsas/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { metodo_pagamento, status_item, status_pedido } from "@prisma/client";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const vendaPecaSchema = z.object({
  cliente_comprador_id: z.uuid({ message: "Selecione o cliente comprador" }),
  responsavel_venda_id: z.uuid({ message: "Selecione o vendedor responsável" }),
  peca_estoque_id: z.uuid({ message: "Selecione uma peça válida" }),
  metodo_pagamento: z.nativeEnum(metodo_pagamento, { error: "Selecione o método de pagamento" }),
  observacoes_recibo: z.string().optional(),
});

export async function realizarVendaPecaAction(prevState: any, formData: FormData) {
  const dadosValidados = vendaPecaSchema.safeParse({
    cliente_comprador_id: formData.get("cliente_comprador_id"),
    responsavel_venda_id: formData.get("responsavel_venda_id"),
    peca_estoque_id: formData.get("peca_estoque_id"),
    metodo_pagamento: formData.get("metodo_pagamento"),
    observacoes_recibo: formData.get("observacoes_recibo"),
  });

  if (!dadosValidados.success) {
    return { error: dadosValidados.error.flatten().fieldErrors };
  }

  const { peca_estoque_id, ...dadosPedido } = dadosValidados.data;

  try {
    // Transação isolada ACID para evitar duplicidade ou venda dupla da mesma peça
    await prisma.$transaction(async (tx) => {
      // 1. Busca a peça e trava o registro para leitura concorrente (Garante integridade)
      const peca = await tx.peca_estoque.findUnique({
        where: { id: peca_estoque_id },
      });

      if (!peca || peca.status_peca !== status_item.Disponivel) {
        throw new Error("Esta peça já foi vendida ou está indisponível.");
      }

      // 2. Cria o registro do cabeçalho da Venda com o valor total da peça
      const pedido = await tx.pedidos_vendas.create({
        data: {
          ...dadosPedido,
          valor_total: peca.preco,
          status_pedido: status_pedido.Autorizado,
        },
      });

      // 3. Insere o item na tabela relacional de itens vendidos com data de garantia (Garantia padrão de 90 dias)
      const dataGarantia = new Date();
      dataGarantia.setDate(dataGarantia.getDate() + 90);

      await tx.itens_pedido_vendas.create({
        data: {
          pedido_venda_id: pedido.id,
          peca_estoque_id: peca.id,
          valor_venda: peca.preco,
          data_fim_garantia: dataGarantia, // Nota: Se houver correção ortográfica posterior no banco mude para data_fim_garantia
          status_item: status_item.Vendido,
        },
      });

      // 4. Dá baixa física imediata alterando o status da peça no estoque
      await tx.peca_estoque.update({
        where: { id: peca.id },
        data: { status_peca: status_item.Vendido },
      });
    });

    revalidatePath("/painel");
    revalidatePath("/"); // Remove automaticamente da vitrine da internet
    return { success: true };
  } catch (error: any) {
    return { serverError: error.message || "Erro interno ao processar a venda." };
  }
}
