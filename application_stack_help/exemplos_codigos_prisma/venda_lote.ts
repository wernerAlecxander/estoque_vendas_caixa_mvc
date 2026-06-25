import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

// Definição do formato que o carrinho deve chegar da sua API
interface ItemCarrinho {
  tipo: 'PECA' | 'SUCATA_NORMAL' | 'SUCATA_COMO_PECA' | 'SERVICO';
  idReferencia: string; // ID da peça, da sucata ou do serviço
  valorVenda: number;
  dataFimGarantia?: Date;
}

async function processarCarrinhoVenda(dados: {
  clienteCompradorId: string;
  responsavelVendaId: string;
  metodoPagamento: any; // Enum metodo_pagamento
  itens: ItemCarrinho[];
}) {
  if (!dados.itens || dados.itens.length === 0) {
    throw new Error("O carrinho não pode estar vazio.");
  }

  return await prisma.$transaction(async (tx) => {
    // 1. Calcular o valor total dinamicamente somando todos os itens do carrinho
    const valorTotalPedido = dados.itens.reduce((acc, item) => acc + item.valorVenda, 0);

    // 2. Criar o registro principal da venda (Cabeçalho do Pedido)
    const pedido = await tx.pedidos_vendas.create({
      data: {
        cliente_comprador_id: dados.clienteCompradorId,
        responsavel_venda_id: dados.responsavelVendaId,
        valor_total: valorTotalPedido,
        metodo_pagamento: dados.metodoPagamento,
        status_pedido: 'Autorizado'
      }
    });

    // 3. Percorrer cada item do carrinho para aplicar as regras de estoque e receitas
    for (const item of dados.itens) {
      const garantia = item.dataFimGarantia || new Date();

      switch (item.tipo) {
        case 'PECA': {
          // Valida a peça
          const peca = await tx.peca_estoque.findUnique({ where: { id: item.idReferencia } });
          if (!peca || peca.status_peca !== 'Disponivel') {
            throw new Error(`Peça ID ${item.idReferencia} indisponível.`);
          }
          // Cria o item do pedido
          await tx.itens_pedido_vendas.create({
            data: {
              pedido_venda_id: pedido.id,
              peca_estoque_id: item.idReferencia,
              valor_venda: item.valorVenda,
              data_fim_garantia: garantia,
              status_item: 'Vendido'
            }
          });
          // Baixa no estoque de peças
          await tx.peca_estoque.update({
            where: { id: item.idReferencia },
            data: { status_peca: 'Vendido' }
          });
          // Gera receita de venda de peça
          await tx.receitas.create({
            data: {
              descricao_receita: `Ref. Pedido N° ${pedido.id} - Peça: ${peca.nome_peca}`,
              categoria_receita: 'Venda peça',
              valor_receita: item.valorVenda,
              responsavel_receita_id: dados.responsavelVendaId
            }
          });
          break;
        }

        case 'SUCATA_NORMAL': {
          // Valida a sucata
          const sucata = await tx.sucata_estoque.findUnique({ where: { id: item.idReferencia } });
          if (!sucata || sucata.status_sucata === 'Vendido') {
            throw new Error(`Sucata ID ${item.idReferencia} indisponível.`);
          }
          // Cria o item do pedido
          await tx.itens_pedido_vendas.create({
            data: {
              pedido_venda_id: pedido.id,
              sucata_estoque_id: item.idReferencia,
              valor_venda: item.valorVenda,
              data_fim_garantia: garantia,
              status_item: 'Vendido'
            }
          });
          // Baixa no estoque de sucatas
          await tx.sucata_estoque.update({
            where: { id: item.idReferencia },
            data: { status_sucata: 'Vendido' }
          });
          // Gera receita de venda de sucata
          await tx.receitas.create({
            data: {
              descricao_receita: `Ref. Pedido N° ${pedido.id} - Sucata Chassi: ${sucata.chassi}`,
              categoria_receita: 'Venda sucata',
              valor_receita: item.valorVenda,
              responsavel_receita_id: dados.responsavelVendaId
            }
          });
          break;
        }

        case 'SUCATA_COMO_PECA': {
          // Valida a sucata que vai virar peça
          const sucata = await tx.sucata_estoque.findUnique({ where: { id: item.idReferencia } });
          if (!sucata || sucata.status_sucata === 'Vendido') {
            throw new Error(`Sucata ID ${item.idReferencia} indisponível para vender como peça.`);
          }
          // Cria o item do pedido apontando para a tabela de sucata
          await tx.itens_pedido_vendas.create({
            data: {
              pedido_venda_id: pedido.id,
              sucata_estoque_id: item.idReferencia,
              valor_venda: item.valorVenda,
              data_fim_garantia: garantia,
              status_item: 'Vendido'
            }
          });
          // Baixa no estoque de sucatas
          await tx.sucata_estoque.update({
            where: { id: item.idReferencia },
            data: { status_sucata: 'Vendido' }
          });
          // Regra solicitada: Gera receita na categoria 'Venda peça'
          await tx.receitas.create({
            data: {
              descricao_receita: `Ref. Pedido N° ${pedido.id} - Sucata vendida como peça (Chassi: ${sucata.chassi})`,
              categoria_receita: 'Venda peça',
              valor_receita: item.valorVenda,
              responsavel_receita_id: dados.responsavelVendaId
            }
          });
          break;
        }

        case 'SERVICO': {
          // Valida o serviço de manutenção executado
          const servico = await tx.servico_manutencao.findUnique({ where: { id: item.idReferencia } });
          if (!servico) {
            throw new Error(`Serviço de manutenção ID ${item.idReferencia} não encontrado.`);
          }
          // Cria o item do pedido vinculado ao serviço
          await tx.itens_pedido_vendas.create({
            data: {
              pedido_venda_id: pedido.id,
              servico_manutencao_id: item.idReferencia,
              valor_venda: item.valorVenda, // Utiliza o valor final cobrado no carrinho
              data_fim_garantia: garantia,
              status_item: 'Aprovado'
            }
          });
          // Altera o status do serviço finalizado
          await tx.servico_manutencao.update({
            where: { id: item.idReferencia },
            data: { status_manutencao: 'Concluída' }
          });
          // Gera receita de serviço de manutenção
          await tx.receitas.create({
            data: {
              descricao_receita: `Ref. Pedido N° ${pedido.id} - Serviço MNT ID: ${servico.id}`,
              categoria_receita: 'Serviço manutenção',
              valor_receita: item.valorVenda,
              responsavel_receita_id: dados.responsavelVendaId
            }
          });
          break;
        }

        default:
          throw new Error("Tipo de item de carrinho inválido.");
      }
    }

    return pedido;
  });
}
/*
//EXEMPLO DE PAYLOAD EM JSON
{
  "clienteCompradorId": "uuid-do-cliente",
  "responsavelVendaId": "uuid-do-vendedor",
  "metodoPagamento": "Pix",
  "itens": [
    { "tipo": "PECA", "idReferencia": "uuid-da-peca-1", "valorVenda": 150.00 },
    { "tipo": "SUCATA_COMO_PECA", "idReferencia": "uuid-da-sucata-x", "valorVenda": 2500.00 },
    { "tipo": "SERVICO", "idReferencia": "uuid-do-servico-y", "valorVenda": 350.00 }
  ]
}
