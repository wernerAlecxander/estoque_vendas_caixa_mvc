// ./src/app/painel/caixa/caixa.test.ts
import { describe, it, expect } from "vitest";

// Função matemática pura simulando a lógica executada no banco de dados do Caixa
function calcularIndicadoresCaixa(vendas: number[], despesas: number[], custoCompras: number) {
  const faturamentoTotal = vendas.reduce((acc, curr) => acc + curr, 0);
  const totalDespesas = despesas.reduce((acc, curr) => acc + curr, 0);

  const margemContribuicaoValor = faturamentoTotal - custoCompras;
  const margemContribuicaoPercentual = faturamentoTotal > 0 ? (margemContribuicaoValor / faturamentoTotal) * 100 : 0;

  const totalPedidos = vendas.length;
  const ticketMedio = totalPedidos > 0 ? faturamentoTotal / totalPedidos : 0;

  const pontoEquilibrio = margemContribuicaoPercentual > 0 ? totalDespesas / (margemContribuicaoPercentual / 100) : 0;

  return {
    faturamentoTotal,
    totalDespesas,
    ticketMedio,
    pontoEquilibrio
  };
}

describe("📊 Suíte de Testes Financeiros — Controle de Caixa", () => {
  
  it("Deve calcular o Ticket Médio corretamente baseado no volume de pedidos", () => {
    const vendasExemplo = [150.00, 350.00, 100.00, 200.00]; // Total = 800
    const despesasExemplo = [100.00];
    const custoCompras = 400.00;

    const resultado = calcularIndicadoresCaixa(vendasExemplo, despesasExemplo, custoCompras);

    // 800 faturamento / 4 pedidos = R$ 200,00 de média por cliente
    expect(resultado.ticketMedio).toBe(200);
  });

  it("Deve calcular o Ponto de Equilíbrio (Break-Even) exato para zerar custos operacionais", () => {
    const vendasExemplo = [1000.00]; 
    const custoCompras = 500.00; // Margem de contribuição de 50%
    const despesasExemplo = [250.00]; // Despesa fixa de R$ 250

    const resultado = calcularIndicadoresCaixa(vendasExemplo, despesasExemplo, custoCompras);

    // Se a despesa é 250 e a margem é 50%, a empresa precisa faturar no mínimo R$ 500 para não ter prejuízo
    expect(resultado.pontoEquilibrio).toBe(500);
  });

  it("Deve retornar zero para Ticket Médio e Ponto de Equilíbrio se não houver faturamento inicial", () => {
    const resultado = calcularIndicadoresCaixa([], [500.00], 0);

    expect(resultado.ticketMedio).toBe(0);
    expect(resultado.pontoEquilibrio).toBe(0);
  });

});
