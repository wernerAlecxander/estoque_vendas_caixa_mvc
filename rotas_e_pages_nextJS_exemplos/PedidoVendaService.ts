import { PrismaClient, TipoMovimentacaoCaixa, StatusMovimentacao, metodo_pagamento } from '@prisma/client';

const prisma = new PrismaClient();

interface RequestCriarPedidoMisto {
  cliente_comprador_id: string;
  responsavel_venda_id: string;
  metodo: metodo_pagamento;
  observacoes?: string;
  // Itens divididos operacionalmente para o cálculo do Custo Marginal
  itens: {
    tipo: 'PECA' | 'SERVICO';
    valor_unitario: number;
    quantidade: number;
  }[];
}

export class PedidoVendaService {
  async executar(dados: RequestCriarPedidoMisto) {
    // 1. Calcular os totais separados por natureza econômica
    let totalPecas = 0;
    let totalServicos = 0;

    dados.itens.forEach(item => {
      const subtotal = item.valor_unitario * item.quantidade;
      if (item.tipo === 'PECA') totalPecas += subtotal;
      if (item.tipo === 'SERVICO') totalServicos += subtotal;
    });

    const valorTotalPedido = totalPecas + totalServicos;

    // 2. Buscar as contas contábeis equivalentes no banco usando os códigos do Seed
    const contaPecas = await prisma.planoContas.findUniqueOrThrow({ where: { codigo_contabil: '1.01' } });
    const contaServicos = await prisma.planoContas.findUniqueOrThrow({ where: { codigo_contabil: '1.02' } });

    // 3. Executar uma Transação ACID no Banco de Dados
    return await prisma.$transaction(async (tx) => {
      
      // Criar o registro principal do pedido (mantendo sua tabela original intacta)
      const pedido = await tx.pedidos_vendas.create({
        data: {
          cliente_comprador_id: dados.cliente_comprador_id,
          responsavel_venda_id: dados.responsavel_venda_id,
          valor_total: valorTotalPedido,
          metodo_pagamento: dados.metodo,
          observacoes_recibo: dados.observacoes,
          status_pedido: 'Autorizado'
        }
      });

      const lancamentosParaCriar = [];

      // Se houver faturamento de peças, cria a linha de receita de produtos
      if (totalPecas > 0) {
        lancamentosParaCriar.push({
          descricao: `Recebimento Ref. Peças do Pedido #${pedido.id.substring(0,8)}`,
          tipo: TipoMovimentacaoCaixa.ENTRADA,
          status: StatusMovimentacao.PAGO, // Pode mudar para PENDENTE se for a prazo
          valor: totalPecas,
          metodo_pagamento: dados.metodo,
          data_movimentacao: new Date(),
          data_vencimento: new Date(),
          pedido_venda_id: pedido.id,
          plano_contas_id: contaPecas.id,
          usuario_caixa_id: dados.responsavel_venda_id // operador do momento
        });
      }

      // Se houver faturamento de serviços, cria a linha isolada de receita de serviços
      if (totalServicos > 0) {
        lancamentosParaCriar.push({
          descricao: `Recebimento Ref. Mão de Obra do Pedido #${pedido.id.substring(0,8)}`,
          tipo: TipoMovimentacaoCaixa.ENTRADA,
          status: StatusMovimentacao.PAGO,
          valor: totalServicos,
          metodo_pagamento: dados.metodo,
          data_movimentacao: new Date(),
          data_vencimento: new Date(),
          pedido_venda_id: pedido.id,
          plano_contas_id: contaServicos.id,
          usuario_caixa_id: dados.responsavel_venda_id
        });
      }

      // Salva em lote os lançamentos divididos dentro do fluxo de caixa
      if (lancamentosParaCriar.length > 0) {
        await tx.fluxo_caixa.createMany({
          data: lancamentosParaCriar
        });
      }

      return pedido;
    });
  }
}
