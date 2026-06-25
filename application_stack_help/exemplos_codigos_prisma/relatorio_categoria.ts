const despesasPorCategoria = await prisma.despesas.groupBy({
  by: ['categoria_id'],
  _sum: {
    valor: true
  },
  orderBy: {
    _sum: {
      valor: 'desc'
    }
  }
});
