import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()

async function registrarVenda(itemId: number, quantidade: number, valorTotal: number, usuario: string) {
  try {
    // Iniciando a transação
    await prisma.$transaction(async (tx) => {
      
      // 1. Registra a movimentação de saída no estoque
      const movimentacao = await tx.movimentacoes_estoque.create({
        data: {
          item_id: itemId,
          tipo: 'SAIDA',
          quantidade: quantidade,
          motivo: 'Venda de item',
          usuario_responsavel: usuario
        }
      });

      // 2. Atualiza a quantidade atual do item subtraindo o estoque
      await tx.itens.update({
        where: { id: itemId },
        data: {
          quantidade_atual: {
            decrement: quantidade // Subtrai de forma segura direto no banco
          }
        }
      });

      // 3. Registra a receita financeira vinculada à movimentação
      await tx.receitas.create({
        data: {
          descricao: `Venda de estoque - Código do movimento: ${movimentacao.id}`,
          valor: valorTotal,
          data_pagamento: new Date(),
          movimentacao_estoque_id: movimentacao.id,
          usuario_responsavel: usuario
          // categoria_id: opcional se tiver configurado
        }
      });
      
    });
    
    console.log("Venda realizada e estoque atualizado com sucesso!");
  } catch (error) {
    // Se QUALQUER uma das 3 operações falhar, o banco volta ao estado original
    console.error("Erro na venda. Nenhuma alteração foi feita no banco:", error);
  }
}
