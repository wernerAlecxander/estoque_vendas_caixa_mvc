// No seu controller/service de vendas (NestJS, Fastify ou Express)
async function criarItemNota(dados: { notaId: string, pecaId: string, cfopId: string }) {
  
  // 1. Busca o código textual do CFOP baseado no ID enviado
  const cfopCadastrado = await prisma.cfops.findUniqueOrThrow({
    where: { id: dados.cfopId }
  });

  // 2. Salva o item da nota gravando o ID para relacionamento e o CÓDIGO para o histórico fiscal
  return await prisma.item_documento_fiscal.create({
    data: {
      documento_fiscal_id: dados.notaId,
      peca_id: dados.pecaId,
      cfop_id: cfopCadastrado.id,
      cfop_codigo: cfopCadastrado.codigo, // "5102" gravado em definitivo na foto da nota
      // ...outros campos de preço e imposto
    }
  });
}
