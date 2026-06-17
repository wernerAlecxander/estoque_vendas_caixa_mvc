'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { ArrowLeft, Search, Trash2, Users, SlidersHorizontal } from 'lucide-react';

// Dados simulados estruturados rigorosamente com base no seu banco PostgreSQL (com UUIDv7)
const CLIENTES_MOCK = [
  { id: '018fbc8a-c423-7a91-bc34-56789abcdef0', nome: 'Ana Souza', cpf: '123.456.789-00', email: 'ana.souza@email.com', telefone: '+55 (95) 99123-4567', cidade: 'Boa Vista', cadastro: '05/06/2026' },
  { id: '018fbc92-ef41-7b82-ad12-98765fedcba1', nome: 'Carlos Mendoza', cpf: '987.654.321-11', email: 'mendoza@email.com', telefone: '+58 412-1234567', cidade: 'Pacaraima', cadastro: '02/06/2026' },
  { id: '018fbca1-332a-7c11-99bc-112233445566', nome: 'John David', cpf: '444.555.666-22', email: 'john.david@email.com', telefone: '+592 612-3456', cidade: 'Georgetown', cadastro: '28/05/2026' },
];

export default function ConsultarClientes() {
  const [clientes, setClientes] = useState(CLIENTES_MOCK);
  const [busca, setBusca] = useState('');

  // Filtra os clientes na tabela por nome, CPF ou E-mail em tempo real enquanto digita
  const clientesFiltrados = clientes.filter(cliente => 
    cliente.nome.toLowerCase().includes(busca.toLowerCase()) ||
    cliente.cpf.includes(busca) ||
    cliente.email.toLowerCase().includes(busca.toLowerCase())
  );

  // Função para simular a deleção de um cliente com modal de confirmação nativo
  const handleDeletar = (id: string, nome: string) => {
    if (confirm(`Tem certeza que deseja remover o cliente "${nome}" do sistema?`)) {
      setClientes(clientes.filter(c => c.id !== id));
      console.log(`Log de exclusão - ID UUIDv7 removido: ${id}`);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-zinc-950 p-6 font-sans transition-colors duration-300">
      
      {/* CABEÇALHO DA TELA */}
      <div className="max-w-6xl mx-auto mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 rounded-lg">
            <Users size={24} />
          </div>
          <div>
            <h1 className="text-xl font-bold text-slate-800 dark:text-zinc-100">Consultar e Gerenciar Clientes</h1>
            <p className="text-xs text-slate-500 dark:text-zinc-400">Pesquise dados, filtre contatos internacionais ou remova registros</p>
          </div>
        </div>

        {/* LINK OBRIGATÓRIO DE VOLTAR PARA A HOME */}
        <Link 
          href="/teste-cliente" 
          className="flex items-center gap-2 text-xs font-medium text-slate-600 dark:text-zinc-400 hover:text-emerald-500 dark:hover:text-emerald-400 transition-colors bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 px-3 py-2 rounded-lg shadow-sm"
        >
          <ArrowLeft size={16} />
          Voltar para Home
        </Link>
      </div>

      {/* BARRA DE FERRAMENTAS (PESQUISA EM TEMPO REAL) */}
      <div className="max-w-6xl mx-auto mb-4 grid grid-cols-1 sm:grid-cols-3 gap-3">
        <div className="sm:col-span-2 relative">
          <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><Search size={16} /></span>
          <input 
            type="text" 
            placeholder="Buscar por nome, CPF ou e-mail do cliente..." 
            value={busca}
            onChange={(e) => setBusca(e.target.value)}
            className="w-full pl-9 pr-3 py-2 text-sm bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all shadow-sm"
          />
        </div>
        <button className="flex items-center justify-center gap-2 text-sm font-medium text-slate-700 dark:text-zinc-300 bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 px-3 py-2 rounded-lg hover:bg-slate-100 dark:hover:bg-zinc-800 transition-colors shadow-sm">
          <SlidersHorizontal size={16} />
          Filtros Avançados
        </button>
      </div>

      {/* TABELA RESPONSIVA CLEAN & MINIMALISTA */}
      <div className="max-w-6xl mx-auto bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 rounded-xl shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-50 dark:bg-zinc-900/50 border-b border-slate-200 dark:border-zinc-800 text-slate-500 dark:text-zinc-400 text-xs font-semibold uppercase tracking-wider">
                <th className="p-4">Nome</th>
                <th className="p-4">CPF</th>
                <th className="p-4">Contato / E-mail</th>
                <th className="p-4">Cidade</th>
                <th className="p-4">Data Cadastro</th>
                <th className="p-4 text-center">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-zinc-800/60 text-sm text-slate-700 dark:text-zinc-300">
              {clientesFiltrados.length > 0 ? (
                clientesFiltrados.map((cliente) => (
                  <tr key={cliente.id} className="hover:bg-slate-50/50 dark:hover:bg-zinc-800/30 transition-colors">
                    <td className="p-4 font-medium text-slate-900 dark:text-zinc-100">{cliente.nome}</td>
                    <td className="p-4 font-mono text-xs text-slate-600 dark:text-zinc-400">{cliente.cpf}</td>
                    <td className="p-4 space-y-0.5">
                      <div className="text-xs font-medium">{cliente.email}</div>
                      <div className="text-xs text-slate-400 dark:text-zinc-500">{cliente.telefone}</div>
                    </td>
                    <td className="p-4 text-xs">{cliente.cidade}</td>
                    <td className="p-4 text-xs text-slate-500 dark:text-zinc-400">{cliente.cadastro}</td>
                    <td className="p-4 text-center">
                      <button 
                        onClick={() => handleDeletar(cliente.id, cliente.nome)}
                        className="p-1.5 text-slate-400 hover:text-red-500 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-950/20 rounded-md transition-all duration-150"
                        title="Deletar Cliente"
                      >
                        <Trash2 size={16} />
                      </button>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="p-8 text-center text-xs text-slate-400 dark:text-zinc-500">
                    Nenhum cliente correspondente encontrado.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
