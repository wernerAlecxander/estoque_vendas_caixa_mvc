// Total de Receitas
const totalReceitas = await prisma.receitas.aggregate({
  _sum: { valor: true }
});

// Total de Despesas Pagas
const totalDespesas = await prisma.despesas.aggregate({
  where: { data_pagamento: { not: null } }, // Apenas o que já foi pago
  _sum: { valor: true }
});

const saldoAtual = (totalReceitas._sum.valor || 0) - (totalDespesas._sum.valor || 0);
console.log(`Saldo em Caixa: R$ ${saldoAtual}`);
