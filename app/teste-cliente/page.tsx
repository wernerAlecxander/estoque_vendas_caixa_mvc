import { listarDadosDoBanco, criarRegistroTeste } from './actions'

export default async function PaginaDeTeste() {
  const resultado = await listarDadosDoBanco()

  return (
    <main className="max-w-2xl mx-auto p-8 font-sans">
      <h1 className="text-3xl font-bold text-gray-800 mb-2">
        Painel de Teste de Conexão
      </h1>
      <p className="text-gray-600 mb-6">
        Next.js 15 + pnpm + Prisma (Docker PostgreSQL)
      </p>

      {/* Formulário que dispara a Server Action ao clicar no botão */}
      <form action={criarRegistroTeste} className="mb-8">
        <button 
          type="submit" 
          className="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded shadow transition-colors"
        >
          + Inserir Registro de Teste
        </button>
      </form>

      <div className="bg-white border rounded-lg shadow-sm p-6">
        <h2 className="text-xl font-semibold text-gray-700 mb-4">
          Dados na Tabela:
        </h2>

        {!resultado.success ? (
          <div className="bg-red-50 text-red-700 p-4 rounded border border-red-200">
            {resultado.error}
          </div>
        ) : resultado.data.length === 0 ? (
          <p className="text-gray-500 italic">
            Conectado com sucesso! Porém, a tabela está vazia. Clique no botão acima para adicionar o primeiro registro.
          </p>
        ) : (
          <ul className="divide-y divide-gray-100">
            {resultado.data.map((item: any) => (
              <li key={item.id} className="py-3 flex justify-between items-center">
                <div>
                  <span className="font-medium text-gray-900">{item.nome}</span>
                  <p className="text-sm text-gray-500">{item.email}</p>
                </div>
                <span className="text-xs bg-gray-100 text-gray-600 px-2 py-1 rounded">
                  ID: {item.id}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </main>
  )
}
