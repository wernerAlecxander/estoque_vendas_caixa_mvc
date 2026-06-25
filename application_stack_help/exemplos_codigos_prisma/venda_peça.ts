import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function criarPedidoVendaPeca(dados: {
  clienteCompradorId: string;
  responsavelVendaId: string;
  metodoPagamento: any; // Seu enum metodo_pagamento
  pecaEstoqueId: string;
  valorVenda: number;
//dataFimGarantia: Date; (o banco tem FUNCTION e TRIGGER que calcula isso)
}) {
  //Abrindo a Transação e Verificando a Peça
  return await prisma.$transaction(async (tx) => {
    // 1. Verifica se a peça está disponível no estoque
    const peca = await tx.peca_estoque.findUnique({
      where: { id: dados.pecaEstoqueId }
    });

    if (!peca || peca.status_peca !== 'Disponivel') {
      throw new Error('Esta peça não está disponível para venda.');
    }

    //Criando o cabeçalho do pedido de venda
    const pedido = await tx.pedidos_vendas.create({
      data: {
        cliente_comprador_id: dados.clienteCompradorId,
        responsavel_venda_id: dados.responsavelVendaId,
        valor_total: dados.valorVenda,
        metodo_pagamento: dados.metodoPagamento,
        status_pedido: 'Autorizado'
      }
    });

    // 3. Insere a peça na tabela de itens do pedido
    await tx.itens_pedido_vendas.create({
      data: {
        pedido_venda_id: pedido.id,
        peca_estoque_id: dados.pecaEstoqueId,
        valor_venda: dados.valorVenda,
        //data_fim_garantia: dados.dataFimGarantia,
        status_item: 'Vendido'
      }
    });

    // 4. Subtrai do estoque atualizando o status da peça
    await tx.peca_estoque.update({
      where: { id: dados.pecaEstoqueId },
      data: { status_peca: 'Vendido' }
    });

    // 5. Envia os dados AUTOMATICAMENTE para a tabela de receitas
    const receita = await tx.receitas.create({
      data: {
        descricao_receita: `Recebimento Ref. Pedido Nº ${pedido.id} - Peça: ${peca.nome_peca}`,
        categoria_receita: 'Venda peça', // Seu enum categoria_receitas
        valor_receita: dados.valorVenda,
        responsavel_receita_id: dados.responsavelVendaId
      }
    });
    // Se chegou até aqui, retorne para o cliente front-end
    return { pedido, receita };
  });
}
