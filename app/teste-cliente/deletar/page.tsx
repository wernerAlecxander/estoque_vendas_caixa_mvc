'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { ArrowLeft, Search, Trash2, UserX, AlertTriangle } from 'lucide-react';
//mportar essa função real de servidor no /estoque_vendas_caixa/app/teste-cliente/deletar
import { deletarClienteDoBanco, buscarClientesNoBanco } from './actions';
import { Timestamp } from 'next/dist/server/lib/cache-handlers/types';

interface Cliente {
  id: string; // UUIDv7
  nome_cliente: string;
  cpf_cliente: string;
  endereco_cliente: string;
  bairro_cliente: string;
  cidade_cliente: string;
  telefone_cliente: string;
  data_nascimento: Date;
  email_cliente: string;
  data_cadastro: Timestamp;
}

export default function DeletarClientes() {
  const [clientes, setClientes] = useState<Cliente[]>([]);
  const [busca, setBusca] = useState('');

  /*
  useEffect(() => {
    async function carregarClientes() {
      try {
        // chamar Server Action que busca os dados no banco
        const dadosReais = await buscarClientesNoBanco(); 
        setClientes(nome_cliente);
      } catch (error) {
        console.error("Erro ao carregar dados:", error);
      } finally {
        setLoading(false);
      }
    }
    

    carregarClientes();
  }, []); // O array vazio garante que a busca aconteça apenas uma vez ao carregar a página
*/
  

  // Filtra os clientes para encontrar rapidamente quem será removido
  const clientesFiltrados = clientes.filter(cliente => 
    cliente.nome_cliente.toLowerCase().includes(busca.toLowerCase()) ||
    cliente.cpf_cliente.includes(busca)
  );

  //
  const handleExcluirDefinitivo = async (id: string, nome: string) => {
  const confirmado = confirm(`Deseja deletar permanentemente o cliente "${nome}"?`);
  
  if (confirmado) {
    // Chama a Server Action que deleta diretamente no PostgreSQL 17
    const resultado = await deletarClienteDoBanco(id);
    
    if (resultado.success) {
      alert("Cliente removido com sucesso do banco de dados!");
    } else {
      alert(`Erro: ${resultado.error}`);
    }
  }
};


  return (
    //
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
                  <div className="text-sm font-semibold text-slate-900 dark:text-zinc-100">{cliente.nome_cliente}</div>
                  <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs text-slate-500 dark:text-zinc-400">
                    <span>CPF: <span className="font-mono text-slate-700 dark:text-zinc-300">{cliente.cpf_cliente}</span></span>
                    <span>•</span>
                    <span>ID: <span className="font-mono text-[10px] bg-slate-100 dark:bg-zinc-800 px-1 py-0.5 rounded">{cliente.id}</span></span>
                  </div>
                </div>

                <div className="flex items-center justify-end shrink-0">
                  <button
                    onClick={() => handleExcluirDefinitivo(cliente.id, cliente.nome_cliente)}
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
