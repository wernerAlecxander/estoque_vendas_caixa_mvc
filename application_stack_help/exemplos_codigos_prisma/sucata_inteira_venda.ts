async function venderSucataInteiraComoPeca(dados: {
  clienteCompradorId: string;
  responsavelVendaId: string;
  metodoPagamento: any;
  sucataEstoqueId: string;
  valorVenda: number;
  dataFimGarantia: Date;
}) {
  return await prisma.$transaction(async (tx) => {
    // 1. Busca a sucata
    const sucata = await tx.sucata_estoque.findUnique({
      where: { id: dados.sucataEstoqueId }
    });

    if (!sucata || sucata.status_sucata === 'Vendido') {
      throw new Error('Sucata indisponível para venda.');
    }

    // 2. Cria o pedido de venda
    const pedido = await tx.pedidos_vendas.create({
      data: {
        cliente_comprador_id: dados.clienteCompradorId,
        responsavel_venda_id: dados.responsavelVendaId,
        valor_total: dados.valorVenda,
        metodo_pagamento: dados.metodoPagamento,
        status_pedido: 'Autorizado',
        observacoes_recibo: "Veículo de sucata vendido inteiro configurado como lote de peças."
      }
    });

    // 3. Vincula o ID da sucata no item (Baixa física do veículo)
    await tx.itens_pedido_vendas.create({
      data: {
        pedido_venda_id: pedido.id,
        sucata_estoque_id: dados.sucataEstoqueId,
        valor_venda: dados.valorVenda,
        data_fim_garantia: dados.dataFimGarantia,
        status_item: 'Vendido'
      }
    });

    // 4. Modifica o status da sucata para vendido
    await tx.sucata_estoque.update({
      where: { id: dados.sucataEstoqueId },
      data: { status_sucata: 'Vendido' }
    });

    // 5. Regra de Negócio: Grava na receita como 'Venda peça'
    const receita = await tx.receitas.create({
      data: {
        descricao_receita: `Venda de Sucata Inteira Corp. Peça - Chassi: ${sucata.chassi}`,
        categoria_receita: 'Venda peça', // <--- Atende seu requisito perfeitamente
        valor_receita: dados.valorVenda,
        responsavel_receita_id: dados.responsavelVendaId
      }
    });

    return { pedido, receita };
  });
}
