// ./app/painel/caixa/page.tsx
import { prisma } from "@/lib/prisma";
import { DollarSign, Percent, Calculator, ShoppingBag, ArrowUpRight, ArrowDownRight } from "lucide-react";

export const dynamic = "force-dynamic";

export default async function ControleCaixaPage() {
  // 1. Busca todos os dados financeiros de forma concorrente
  const [vendas, despesas, compras] = await Promise.all([
    prisma.pedidos_vendas.findMany({
      where: { status_pedido: "Autorizado" },
      select: { valor_total: true }
    }),
    prisma.despesas.findMany({
      select: { valor_despesa: true }
    }),
    prisma.sucata_compras.aggregate({
      _sum: { valor_compra: true }
    })
  ]);

  // 2. Cálculos de Faturamento e Despesas
  const faturamentoTotal = vendas.reduce((acc, curr) => acc + Number(curr.valor_total), 0);
  const totalDespesas = despesas.reduce((acc, curr) => acc + Number(curr.valor_despesa), 0);
  const totalCompras = Number(compras._sum.valor_compra) || 0;

  // 3. Cálculo da Margem de Contribuição (Faturamento - Custos Variáveis de Compra)
  const margemContribuicaoValor = faturamentoTotal - totalCompras;
  const margemContribuicaoPercentual = faturamentoTotal > 0 ? (margemContribuicaoValor / faturamentoTotal) * 100 : 0;

  // 4. Indicador: Ticket Médio
  const totalPedidos = vendas.length;
  const ticketMedio = totalPedidos > 0 ? faturamentoTotal / totalPedidos : 0;

  // 5. Indicador: Ponto de Equilíbrio
  const pontoEquilibrio = margemContribuicaoPercentual > 0 ? totalDespesas / (margemContribuicaoPercentual / 100) : 0;

  // 6. Lucro Líquido Real e Margem Líquida
  const lucroLiquido = faturamentoTotal - totalDespesas;
  const margemLiquidaPercentual = faturamentoTotal > 0 ? (lucroLiquido / faturamentoTotal) * 100 : 0;

  return (
    <div className="space-y-8">
      {/* Cabeçalho */}
      <div>
        <h1 className="text-xl font-black tracking-tight text-gray-900 dark:text-white uppercase flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-[#0091FF]" />
          Análise de Indicadores de Caixa
        </h1>
        <p className="text-xs text-gray-500 mt-1 font-medium">
          Métricas de viabilidade econômica e lucratividade real do ferro velho.
        </p>
      </div>

      {/* Grid Superior: Indicadores Básicos de Caixa */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
        <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 p-5 rounded-2xl shadow-sm">
          <div className="flex justify-between items-center text-gray-400">
            <span className="text-[11px] font-bold uppercase tracking-wider">Entrada Bruta (Faturamento)</span>
            <ArrowUpRight className="h-4 w-4 text-[#00E676]" />
          </div>
          <p className="text-2xl font-black mt-3 text-gray-900 dark:text-white">
            R$ {faturamentoTotal.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
          </p>
        </div>

        <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 p-5 rounded-2xl shadow-sm">
          <div className="flex justify-between items-center text-gray-400">
            <span className="text-[11px] font-bold uppercase tracking-wider">Saídas Totais (Despesas)</span>
            <ArrowDownRight className="h-4 w-4 text-red-500" />
          </div>
          <p className="text-2xl font-black mt-3 text-gray-900 dark:text-white">
            R$ {totalDespesas.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
          </p>
        </div>

        <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 p-5 rounded-2xl shadow-sm">
          <div className="flex justify-between items-center text-gray-400">
            <span className="text-[11px] font-bold uppercase tracking-wider">Resultado Líquido</span>
            <span className={`text-[10px] px-2 py-0.5 font-bold rounded-full ${lucroLiquido >= 0 ? "bg-[#00E676]/10 text-[#00E676]" : "bg-red-500/10 text-red-500"}`}>
              {margemLiquidaPercentual.toFixed(1)}% Margem
            </span>
          </div>
          <p className={`text-2xl font-black mt-3 ${lucroLiquido >= 0 ? "text-[#00E676]" : "text-red-500"}`}>
            R$ {lucroLiquido.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
          </p>
        </div>
      </div>

      {/* Seção Focada em Indicadores Estratégicos (Estilo DLTEC Premium Dark) */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
        
        {/* Card: Ponto de Equilíbrio */}
        <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 flex flex-col justify-between space-y-6 shadow-sm">
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs font-bold text-[#0091FF] uppercase tracking-wider">
              <Calculator className="h-4 w-4" />
              <span>Ponto de Equilíbrio Comercial</span>
            </div>
            <p className="text-[11px] text-gray-400 leading-relaxed font-medium">
              Este é o faturamento mínimo mensal que a empresa precisa alcançar para pagar todas as contas fixas e variáveis. Acima deste valor, o ferro velho entra na zona de lucro real.
            </p>
          </div>

          <div className="bg-gray-50 dark:bg-[#0B0F19] rounded-xl p-4 border border-gray-100 dark:border-gray-800/60">
            <span className="text-[10px] font-bold text-gray-400 block uppercase">Faturamento Alvo Mínimo</span>
            <span className="text-3xl font-black text-gray-900 dark:text-white block mt-1 tracking-tight">
              R$ {pontoEquilibrio.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div className="text-[10px] text-gray-400 font-semibold space-y-1.5 bg-gray-50/50 dark:bg-gray-900/20 p-3 rounded-xl border border-gray-100 dark:border-gray-800/40">
            <div className="flex justify-between"><span>Margem de Contribuição Atual:</span> <span className="text-gray-900 dark:text-white font-mono">{margemContribuicaoPercentual.toFixed(1)}%</span></div>
            <div className="flex justify-between"><span>Status do Faturamento:</span> <span className={faturamentoTotal >= pontoEquilibrio ? "text-[#00E676]" : "text-amber-500"}>{faturamentoTotal >= pontoEquilibrio ? "🔥 Acima do Ponto" : "⚠ Abaixo do Ponto"}</span></div>
          </div>
        </div>

        {/* Card: Ticket Médio */}
        <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl p-6 flex flex-col justify-between space-y-6 shadow-sm">
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-xs font-bold text-[#0091FF] uppercase tracking-wider">
              <ShoppingBag className="h-4 w-4" />
              <span>Ticket Médio por Venda</span>
            </div>
            <p className="text-[11px] text-gray-400 leading-relaxed font-medium">
              Representa o valor médio que cada comprador gasta por transação em seu balcão ou e-commerce. Útil para criar estratégias de aumento de vendas casadas de peças avulsas.
            </p>
          </div>

          <div className="bg-gray-50 dark:bg-[#0B0F19] rounded-xl p-4 border border-gray-100 dark:border-gray-800/60">
            <span className="text-[10px] font-bold text-gray-400 block uppercase">Média Gasta por Cliente</span>
            <span className="text-3xl font-black text-gray-900 dark:text-white block mt-1 tracking-tight">
              R$ {ticketMedio.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
            </span>
          </div>

          <div className="text-[10px] text-gray-400 font-semibold space-y-1.5 bg-gray-50/50 dark:bg-gray-900/20 p-3 rounded-xl border border-gray-100 dark:border-gray-800/40">
            <div className="flex justify-between"><span>Total de Pedidos Processados:</span> <span className="text-gray-900 dark:text-white font-mono">{totalPedidos} ordens</span></div>
            <div className="flex justify-between"><span>Eficiência de Caixa:</span> <span className="text-white">Estável</span></div>
          </div>
        </div>

      </div>
    </div>
  );
}
