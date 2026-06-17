'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { ArrowLeft, Search, Trash2, UserX, AlertTriangle } from 'lucide-react';

// Dados simulados estruturados com base no seu banco PostgreSQL (UUIDv7)
const CLIENTES_MOCK = [
  { id: '018fbc8a-c423-7a91-bc34-56789abcdef0', nome: 'Ana Souza', cpf: '123.456.789-00', email: 'ana.souza@email.com', cidade: 'Boa Vista' },
  { id: '018fbc92-ef41-7b82-ad12-98765fedcba1', nome: 'Carlos Mendoza', cpf: '987.654.321-11', email: 'mendoza@email.com', cidade: 'Pacaraima' },
  { id: '018fbca1-332a-7c11-99bc-112233445566', nome: 'John David', cpf: '444.555.666-22', email: 'john.david@email.com', cidade: 'Georgetown' },
];

export default function DeletarClientes() {
  const [clientes, setClientes] = useState(CLIENTES_MOCK);
  const [busca, setBusca] = useState('');

  // Filtra os clientes para encontrar rapidamente quem será removido
  const clientesFiltrados = clientes.filter(cliente => 
    cliente.nome.toLowerCase().includes(busca.toLowerCase()) ||
    cliente.cpf.includes(busca)
  );

  // Executa a exclusão definitiva simulada
  const handleExcluirDefinitivo = (id: string, nome: string) => {
    const confirmado = confirm(`Atenção: Você tem certeza que deseja deletar permanentemente o cliente "${nome}"? Esta ação não poderá ser desfeita no banco de dados.`);
    
    if (confirmado) {
      setClientes(clientes.filter(c => c.id !== id));
      console.log(`Sucesso: Registro com ID UUIDv7 ${id} foi deletado.`);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-zinc-950 p-6 font-sans transition-colors duration-300">
      
      {/* CABEÇALHO DA TELA COM ALERTA VISUAL */}
      <div className="max-w-5xl mx-auto mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-rose-500/10 text-rose-600 dark:text-rose-400 rounded-lg">
            <UserX size={24} />
          </div>
          <div>
            <h1 className="text-xl font-bold text-slate-800 dark:text-zinc-100">Remover Clientes do Sistema</h1>
            <p className="text-xs text-slate-500 dark:text-zinc-400">Exclusão permanente de registros e históricos de manutenção associados</p>
          </div>
        </div>

        {/* LINK OBRIGATÓRIO DE VOLTAR PARA A HOME */}
        <Link 
          href="/teste-cliente" 
          className="flex items-center gap-2 text-xs font-medium text-slate-600 dark:text-zinc-400 hover:text-rose-500 dark:hover:text-rose-400 transition-colors bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 px-3 py-2 rounded-lg shadow-sm"
        >
          <ArrowLeft size={16} />
          Voltar para Home
        </Link>
      </div>

      {/* CARD DE ADVERTÊNCIA CLEAN */}
      <div className="max-w-5xl mx-auto mb-6 bg-amber-50 dark:bg-amber-950/10 border border-amber-200 dark:border-amber-900/50 rounded-xl p-4 flex items-start gap-3">
        <AlertTriangle className="text-amber-600 dark:text-amber-500 shrink-0 mt-0.5" size={18} />
        <div className="text-xs text-amber-800 dark:text-amber-400/90 leading-relaxed">
          <strong>Regra de Integridade Referencial:</strong> Ao deletar um cliente nesta tela, devido à configuração <code>ON DELETE CASCADE</code> do seu banco de dados, todos os <strong>veículos em manutenção</strong> vinculados a este ID também serão apagados de forma automática.
        </div>
      </div>

      {/* BARRA DE PESQUISA */}
      <div className="max-w-5xl mx-auto mb-4 relative">
        <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><Search size={16} /></span>
        <input 
          type="text" 
          placeholder="Digite o nome ou CPF para localizar o registro que deseja remover..." 
          value={busca}
          onChange={(e) => setBusca(e.target.value)}
          className="w-full pl-9 pr-3 py-2 text-sm bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-rose-500 transition-all shadow-sm"
        />
      </div>

      {/* LISTA DE DELEÇÃO */}
      <div className="max-w-5xl mx-auto bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 rounded-xl shadow-sm overflow-hidden">
        <div className="divide-y divide-slate-100 dark:divide-zinc-800/60">
          {clientesFiltrados.length > 0 ? (
            clientesFiltrados.map((cliente) => (
              <div 
                key={cliente.id} 
                className="p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50/50 dark:hover:bg-zinc-800/20 transition-colors"
              >
                <div className="space-y-1">
                  <div className="text-sm font-semibold text-slate-900 dark:text-zinc-100">{cliente.nome}</div>
                  <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-slate-500 dark:text-zinc-400">
                    <span>CPF: <span className="font-mono text-slate-700 dark:text-zinc-300">{cliente.cpf}</span></span>
                    <span>•</span>
                    <span>ID: <span className="font-mono text-[10px] bg-slate-100 dark:bg-zinc-800 px-1 py-0.5 rounded">{cliente.id}</span></span>
                  </div>
                </div>

                <div className="flex items-center justify-end shrink-0">
                  <button
                    onClick={() => handleExcluirDefinitivo(cliente.id, cliente.nome)}
                    className="flex items-center gap-2 text-xs font-medium text-rose-600 dark:text-rose-400 hover:text-white dark:hover:text-white hover:bg-rose-600 dark:hover:bg-rose-500 border border-rose-200 dark:border-rose-900/50 px-3 py-2 rounded-lg transition-all active:scale-95 shadow-sm"
                  >
                    <Trash2 size={14} />
                    Excluir Permanentemente
                  </button>
                </div>
              </div>
            ))
          ) : (
            <div className="p-8 text-center text-xs text-slate-400 dark:text-zinc-500">
              Nenhum registro encontrado para exclusão.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
