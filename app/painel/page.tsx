// ./app/painel/page.tsx
import { prisma } from "@/lib/prisma";
import { BarChart3, TrendingUp, AlertTriangle, DollarSign } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  // 1. FATURAMENTO TOTAL (Receita Bruta - Somatória de Vendas Concluídas)
  const vendas = await prisma.pedidos_vendas.findMany({
    where: { status_pedido: "Autorizado" },
    select: { valor_total: true }
  });
  const faturamentoTotal = vendas.reduce((acc, curr) => acc + Number(curr.valor_total), 0);

  // 2. TOTAL DE DESPESAS (Fixas + Variáveis)
  const despesasDoBanco = await prisma.despesas.findMany({
    select: { valor_despesa: true }
  });
  const totalDespesas = despesasDoBanco.reduce((acc, curr) => acc + Number(curr.valor_despesa), 0);

  // 3. MARGEM DE CONTRIBUIÇÃO (Cálculo Simulado com base nos itens vendidos menos o custo estimado)
  const totalCustoPecasCompradas = await prisma.sucata_compras.aggregate({
    _sum: { valor_compra: true }
  });
  const custosVariaveis = Number(totalCustoPecasCompradas._sum.valor_compra) || 0;
  const margemContribuicaoValor = faturamentoTotal - custosVariaveis;
  const margemContribuicaoPercentual = faturamentoTotal > 0 ? (margemContribuicaoValor / faturamentoTotal) * 100 : 0;

  // 4. MARGEM LÍQUIDA REAL
  const lucroLiquido = faturamentoTotal - totalDespesas;
  const margemLiquidaPercentual = faturamentoTotal > 0 ? (lucroLiquido / faturamentoTotal) * 100 : 0;

  // 5. PONTO DE EQUILÍBRIO (Custos Fixos / Margem de Contribuição em %)
  const pontoEquilibrio = margemContribuicaoPercentual > 0 ? (totalDespesas / (margemContribuicaoPercentual / 100)) : 0;

  return (
    <div className="space-y-8 animate-fade-in">
      
      {/* Header Contextual */}
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase">
          Visão Geral dos Indicadores
        </h1>
        <p className="text-xs text-gray-500 dark:text-gray-400 mt-1 font-medium">
          Métricas calculadas em tempo real com base no fluxo de estoque e caixa.
        </p>
      </div>

      {/* Grid de Cartões de Performance (Estilo DLTEC Premium Dark) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        
        {/* Faturamento - Paleta Azul */}
        <div className="p-5 rounded-2xl bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 shadow-sm flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wide">Faturamento Bruto</span>
            <DollarSign className="h-4 w-4 text-[#0091FF]" />
          </div>
          <div className="mt-4">
            <span className="text-2xl font-black tracking-tight text-gray-900 dark:text-white">
              R$ {faturamentoTotal.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
            </span>
            <span className="block text-[10px] text-gray-400 mt-1 font-medium">Volume total faturado</span>
          </div>
        </div>

        {/* Margem de Contribuição - Paleta Verde */}
        <div className="p-5 rounded-2xl bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 shadow-sm flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wide">Margem de Contribuição</span>
            <TrendingUp className="h-4 w-4 text-[#00E676]" />
          </div>
          <div className="mt-4">
            <span className="text-2xl font-black tracking-tight text-[#00E676]">
              {margemContribuicaoPercentual.toFixed(1)}%
            </span>
            <span className="block text-[10px] text-gray-400 mt-1 font-medium">
              Sobra de caixa: R$ {margemContribuicaoValor.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
            </span>
          </div>
        </div>

        {/* Margem Líquida - Paleta Verde/Azul */}
        <div className="p-5 rounded-2xl bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 shadow-sm flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wide">Margem Líquida</span>
            <BarChart3 className="h-4 w-4 text-[#00E676]" />
          </div>
          <div className="mt-4">
            <span className={`text-2xl font-black tracking-tight ${lucroLiquido >= 0 ? "text-gray-900 dark:text-white" : "text-red-500"}`}>
              {margemLiquidaPercentual.toFixed(1)}%
            </span>
            <span className="block text-[10px] text-gray-400 mt-1 font-medium">
              Lucro real após descontar despesas
            </span>
          </div>
        </div>

        {/* Ponto de Equilíbrio - Paleta Amarela */}
        <div className="p-5 rounded-2xl bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 shadow-sm flex flex-col justify-between">
          <div className="flex items-center justify-between">
            <span className="text-xs font-bold text-gray-500 uppercase tracking-wide">Ponto de Equilíbrio</span>
            <AlertTriangle className="h-4 w-4 text-[#FFD600]" />
          </div>
          <div className="mt-4">
            <span className="text-2xl font-black tracking-tight text-[#FFD600]">
              R$ {pontoEquilibrio.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
            </span>
            <span className="block text-[10px] text-gray-400 mt-1 font-medium">Meta mínima para zerar custos</span>
          </div>
        </div>

      </div>
    </div>
  );
}
