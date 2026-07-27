import { PrismaClient, TipoMovimentacaoCaixa } from '@prisma/client';

const prisma = new PrismaClient();

export class RelatorioDREService {
  async gerarDRE(ano: number, mes: number) {
    const dataInicio = new Date(ano, mes - 1, 1);
    const dataFim = new Date(ano, mes, 0, 23, 59, 59);

    // 1. Agrupa os lançamentos do fluxo de caixa somando os valores por conta contábil
    const agrupadoFinanceiro = await prisma.fluxo_caixa.groupBy({
      by: ['plano_contas_id'],
      where: {
        data_movimentacao: {
          gte: dataInicio,
          lte: dataFim,
        },
        // Na DRE por Regime de Competência puro, avaliamos o fato gerador (data_movimentacao).
        // Se preferir DRE por regime de Caixa puro, descomente a linha abaixo:
        // status: 'PAGO'
      },
      _sum: {
        valor: true,
      },
    });

    // 2. Busca os detalhes textuais e ordenadores de cada conta (codigo_contabil, nome)
    const planoContasCompleto = await prisma.planoContas.findMany({
      orderBy: {
        codigo_contabil: 'asc', // Garante a ordenação nativa por string: 1.01, 1.02, 2.01...
      },
    });

    // 3. Junta as somas matemáticas à árvore conceitual da DRE
    const linhasDRE = planoContasCompleto.map((conta) => {
      const correspondente = agrupadoFinanceiro.find(
        (item) => item.plano_contas_id === conta.id
      );
      
      const totalGerado = correspondente?._sum.valor ? Number(correspondente._sum.valor) : 0;

      return {
        codigo: conta.codigo_contabil,
        descricao: conta.nome_conta,
        tipo_grupo: conta.tipo_dre, // RECEITA_BRUTA, CUSTO_VARIAVEL...
        valor: totalGerado
      };
    });

    // 4. Estrutura o objeto de retorno calculando Margens e Lucro Líquido
    const receitaBruta = linhasDRE.filter(l => l.tipo_grupo === 'RECEITA_BRUTA').reduce((a, b) => a + b.valor, 0);
    const deducoes = linhasDRE.filter(l => l.tipo_grupo === 'DEDUCAO_RECEITA').reduce((a, b) => a + b.valor, 0);
    const custosVariaveis = linhasDRE.filter(l => l.tipo_grupo === 'CUSTO_VARIAVEL').reduce((a, b) => a + b.valor, 0);
    const despesasFixas = linhasDRE.filter(l => l.tipo_grupo === 'DESPESA_FIXA').reduce((a, b) => a + b.valor, 0);

    const receitaLiquida = receitaBruta - deducoes;
    const margemContribuicao = receitaLiquida - custosVariaveis; // Core do seu modelo Marginal
    const resultadoOperacionalLucro = margemContribuicao - despesasFixas;

    return {
      periodo: `${mes}/${ano}`,
      estrutura_contas: linhasDRE, // Lista ordenada pronta para dar o .map() na tabela do Frontend
      resumos_calculados: {
        receita_bruta: receitaBruta,
        deducoes: deducoes,
        receita_liquida: receitaLiquida,
        custos_variaveis_marginais: custosVariaveis,
        margem_contribuicao: margemContribuicao,
        custos_despesas_fixas: despesasFixas,
        lucro_liquido_periodo: resultadoOperacionalLucro,
      },
    };
  }
}
