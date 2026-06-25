const estoqueBaixo = await prisma.itens.findMany({
  where: {
    quantidade_atual: {
      lt: 5 // Retorna itens com quantidade menor que 5 (por exemplo)
    }
  },
  select: {
    nome: true,
    quantidade_atual: true,
    unidade_medida: true
  }
});
