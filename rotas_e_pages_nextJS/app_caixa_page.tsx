// app/caixa/page.tsx
import { obterExtratoCaixa } from "@/actions/caixa"; 

export default async function PaginaExtratoCaixa() {
  const lancamentos = await obterExtratoCaixa();

  return (
    <div className="p-6">
      <h1>Histórico do Fluxo de Caixa</h1>
      <ul>
        {lancamentos.map((item) => (
          <li key={item.id} className="border-b p-2">
            {/* Graças ao include, você pode acessar dados das tabelas vizinhas assim: */}
            <strong>Operador:</strong> {item.usuario_caixa.nome} <br />
            <strong>Valor:</strong> R$ {item.valor} <br />
            <strong>Produto:</strong> {item.estoque_objetos_duraveis?.nome || "Outro item"}
          </li>
        ))}
      </ul>
    </div>
  );
}
