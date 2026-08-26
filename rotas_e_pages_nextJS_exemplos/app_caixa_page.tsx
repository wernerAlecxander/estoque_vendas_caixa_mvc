// Importa uma Server Action responsável por buscar os dados diretamente do banco de dados (Prisma)
import { obterExtratoCaixa } from "@/actions/caixa"; 

/**
 * Componente de Página assíncrono (Server Component por padrão no Next.js).
 * Sendo um Server Component, ele executa totalmente no servidor, garantindo segurança
 * nas consultas ao banco e entregando o HTML já pronto para o navegador do cliente.
 */
export default async function PaginaExtratoCaixa() {
  // Executa a busca dos lançamentos de caixa de forma assíncrona antes de renderizar a interface
  const lancamentos = await obterExtratoCaixa();

  return (
    // Estrutura visual principal da página com espaçamento interno (padding de 24px via Tailwind)
    <div className="p-6">
      <h1>Histórico do Fluxo de Caixa</h1>
      
      {/* Lista que abrigará cada um dos registros financeiros retornados */}
      <ul>
        {/* 
          Mapeia o array de lançamentos para transformar dados brutos do banco 
          em elementos visuais de lista (<li>) do React.
        */}
        {lancamentos.map((item) => (
          /* 
            Cada item gerado por um laço de repetição no React necessita de uma propriedade 'key' 
            única e estável para otimizar a renderização e o controle do DOM.
          */
          <li key={item.id} className="border-b p-2">
            
            {/* 
              Acessa a relação de chave estrangeira 'usuario_caixa'. 
              Exibe o nome do funcionário que realizou o fechamento ou movimentação.
            */}
            <strong>Operador:</strong> {item.usuario_caixa.nome} <br />
            
            {/* Exibe o valor financeiro bruto da transação registrada */}
            <strong>Valor:</strong> R$ {item.valor} <br />
            
            {/* 
              Acessa a relação condicional com a tabela de produtos/itens.
              O operador de encadeamento opcional (?.) evita quebras caso o relacionamento seja nulo.
              O operador de coalescência nula (||) serve como fallback (plano de fundo), 
              exibindo "Outro item" se 'estoque_objetos_duraveis' ou o 'nome' não existirem.
            */}
            <strong>Produto:</strong> {item.estoque_objetos_duraveis?.nome || "Outro item"}
            
          </li>
        ))}
      </ul>
    </div>
  );
}
