import { ListagemEtiquetasClient } from "./ListagemEtiquetasClient";

// Se você busca as peças do banco de dados, faça aqui dentro:
async function buscarPecasEstoque() {
  // Exemplo: const { data } = await supabase.from('pecas').select('*, modelos(*)');
  // return data || [];
  return []; // Substitua pelo seu fetch real do banco de dados
}

export default async function EtiquetasDuraveisPage() {
  const pecas = await buscarPecasEstoque();

  return (
    <div className="p-6 space-y-4">
      <div>
        <h1 className="text-xl font-black uppercase tracking-wider text-gray-900 dark:text-white">Etiquetas Duráveis</h1>
        <p className="text-xs text-gray-400">Gerencie e emita códigos de barra térmicos para o estoque.</p>
      </div>

      {/* Renderiza o componente cliente passando os dados buscados no servidor */}
      <ListagemEtiquetasClient pecas={pecas} />
    </div>
  );
}
