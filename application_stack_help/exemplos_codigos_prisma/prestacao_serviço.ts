async function faturarServicoManutencao(dados: {
  pedidoVendaId?: string; // Pode criar um pedido novo ou usar um existente
  clienteId: string;
  responsavelVendaId: string;
  metodoPagamento: any;
  servicoManutencaoId: string;
}) {
  return await prisma.$transaction(async (tx) => {
    // 1. Busca os dados do serviço executado para saber o preço
    const servico = await tx.servico_manutencao.findUnique({
      where: { id: dados.servicoManutencaoId }
    });

    if (!servico) throw new Error('Serviço de manutenção não encontrado.');

    // 2. Cria o pedido de venda para o serviço
    const pedido = await tx.pedidos_vendas.create({
      data: {
        cliente_comprador_id: dados.clienteId,
        responsavel_venda_id: dados.responsavelVendaId,
        valor_total: servico.preco,
        metodo_pagamento: dados.metodoPagamento,
        status_pedido: 'Autorizado'
      }
    });

    // 3. Vincula o serviço na tabela de itens
    await tx.itens_pedido_vendas.create({
      data: {
        pedido_venda_id: pedido.id,
        servico_manutencao_id: dados.servicoManutencaoId,
        valor_venda: servico.preco,
        data_fim_garantia: new Date(), // Serviços podem não ter garantia padrão de peça, ou define uma regra
        status_item: 'Aprovado'
      }
    });

    // 4. Atualiza o status do serviço para Concluído
    await tx.servico_manutencao.update({
      where: { id: dados.servicoManutencaoId },
      data: { status_manutencao: 'Concluída' }
    });

    // 5. Registra automaticamente na tabela receita
    const receita = await tx.receitas.create({
      data: {
        descricao_receita: `Faturamento de Serviço O.S: ${servico.id} - ${servico.descricao_manutencao.substring(0, 50)}`,
        categoria_receita: 'Serviço manutenção', // Força a categoria correta de receita
        valor_receita: servico.preco,
        responsavel_receita_id: dados.responsavelVendaId
      }
    });

    return { pedido, receita };
  });
}
