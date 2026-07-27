import { addDays } from 'date-fns'; // Exemplo usando date-fns

async function criarParcelasVenda(pedidoId: string, planoContasId: string) {
  const valorParcela = 1000.00;
  const prazos =;
  const dataVenda = new Date();

  // Cria um array com os 3 lançamentos estruturados
  const parcelas = prazos.map((dias) => {
    return {
      valor: valorParcela,
      tipo: 'ENTRADA',
      status: 'PENDENTE',
      data_vencimento: addDays(dataVenda, dias), // Calcula +30, +60 e +90 dias
      plano_contas_id: planoContasId,
      pedido_id: pedidoId,
    };
  });

  // Salva todas as parcelas de uma vez só no banco de dados
  await prisma.movimentacao.createMany({
    data: parcelas,
  });
}
