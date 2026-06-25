async function criarPedidoVendaSucata(dados: {
  clienteCompradorId: string;
  responsavelVendaId: string;
  metodoPagamento: any;
  sucataEstoqueId: string;
  valorVenda: number;
  dataFimGarantia: Date;
}) {
  return await prisma.$transaction(async (tx) => {
    // 1. Verifica se a sucata está disponível
    const sucata = await tx.sucata_estoque.findUnique({
      where: { id: dados.sucataEstoqueId }
    });

    if (!sucata || sucata.status_sucata === 'Vendido') {
      throw new Error('Esta sucata já foi vendida ou está indisponível.');
    }

    // 2. Cria o pedido de venda
    const pedido = await tx.pedidos_vendas.create({
      data: {
        cliente_comprador_id: dados.clienteCompradorId,
        responsavel_venda_id: dados.responsavelVendaId,
        valor_total: dados.valorVenda,
        metodo_pagamento: dados.metodoPagamento,
        status_pedido: 'Autorizado'
      }
    });

    // 3. Vincula a sucata ao item do pedido (usando seu novo campo opcional!)
    await tx.itens_pedido_vendas.create({
      data: {
        pedido_venda_id: pedido.id,
        sucata_estoque_id: dados.sucataEstoqueId,
        valor_venda: dados.valorVenda,
        data_fim_garantia: dados.dataFimGarantia,
        status_item: 'Vendido'
      }
    });

    // 4. Subtrai do estoque atualizando o status da sucata
    await tx.sucata_estoque.update({
      where: { id: dados.sucataEstoqueId },
      data: { status_sucata: 'Vendido' }
    });

    // 5. Envia automaticamente para a receita como Venda de Sucata
    const receita = await tx.receitas.create({
      data: {
        descricao_receita: `Recebimento Ref. Pedido Nº ${pedido.id} - Sucata Chassi: ${sucata.chassi}`,
        categoria_receita: 'Venda sucata',
        valor_receita: dados.valorVenda,
        responsavel_receita_id: dados.responsavelVendaId
      }
    });

    return { pedido, receita };
  });
}
