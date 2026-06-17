'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { ArrowLeft, UserPlus, Phone, Mail, MapPin, Calendar, CreditCard } from 'lucide-react';

export default function CadastrarCliente() {
  const [formData, setFormData] = useState({
    nome: '',
    cpf: '',
    email: '',
    telefone: '',
    dataNascimento: '',
    endereco: '',
    bairro: '',
    cidade: 'Boa Vista'
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Integração futura com o banco via API/Server Action
    console.log('Dados do cliente enviados:', formData);
    alert('Cliente cadastrado com sucesso! (Simulação)');
  };

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-zinc-950 p-6 font-sans transition-colors duration-300">
      {/* CABEÇALHO DA PÁGINA */}
      <div className="max-w-4xl mx-auto mb-6 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 rounded-lg">
            <UserPlus size={24} />
          </div>
          <div>
            <h1 className="text-xl font-bold text-slate-800 dark:text-zinc-100">Cadastrar Novo Cliente</h1>
            <p className="text-xs text-slate-500 dark:text-zinc-400">Insira os dados do cliente para manutenção ou vendas</p>
          </div>
        </div>

        {/* LINK OBRIGATÓRIO DE VOLTAR PARA A HOME */}
        <Link 
          href="/painel" 
          className="flex items-center gap-2 text-xs font-medium text-slate-600 dark:text-zinc-400 hover:text-emerald-500 dark:hover:text-emerald-400 transition-colors bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 px-3 py-2 rounded-lg shadow-sm"
        >
          <ArrowLeft size={16} />
          Voltar para Home
        </Link>
      </div>

      {/* FORMULÁRIO DESIGN CLEAN */}
      <div className="max-w-4xl mx-auto bg-white dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 rounded-xl shadow-sm p-6">
        <form onSubmit={handleSubmit} className="space-y-6">
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {/* Nome Completo */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">Nome Completo</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><UserPlus size={16} /></span>
                <input required type="text" name="nome" value={formData.nome} onChange={handleChange} placeholder="Ex: João Silva" 
                  className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 dark:bg-zinc-950 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all" />
              </div>
            </div>

            {/* CPF */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">CPF</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><CreditCard size={16} /></span>
                <input required type="text" name="cpf" value={formData.cpf} onChange={handleChange} placeholder="000.000.000-00" 
                  className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 dark:bg-zinc-950 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all" />
              </div>
            </div>

            {/* Email */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">E-mail</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><Mail size={16} /></span>
                <input required type="email" name="email" value={formData.email} onChange={handleChange} placeholder="joao@email.com" 
                  className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 dark:bg-zinc-950 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all" />
              </div>
            </div>

            {/* Telefone Internacional */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">Telefone / WhatsApp</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><Phone size={16} /></span>
                <input required type="text" name="telefone" value={formData.telefone} onChange={handleChange} placeholder="+55 (95) 99999-9999" 
                  className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 dark:bg-zinc-950 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all" />
              </div>
            </div>

            {/* Data de Nascimento */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">Data de Nascimento</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><Calendar size={16} /></span>
                <input type="date" name="dataNascimento" value={formData.dataNascimento} onChange={handleChange} 
                  className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 dark:bg-zinc-950 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all" />
              </div>
            </div>

            {/* Endereço */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">Endereço (Rua e Número)</label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-slate-400"><MapPin size={16} /></span>
                <input type="text" name="endereco" value={formData.endereco} onChange={handleChange} placeholder="Av. Principal, 123" 
                  className="w-full pl-9 pr-3 py-2 text-sm bg-slate-50 dark:bg-zinc-950 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all" />
              </div>
            </div>

            {/* Bairro */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">Bairro</label>
              <input type="text" name="bairro" value={formData.bairro} onChange={handleChange} placeholder="Centro" 
                className="w-full px-3 py-2 text-sm bg-slate-50 dark:bg-zinc-950 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-800 dark:text-zinc-100 focus:outline-none focus:border-emerald-500 transition-all" />
            </div>

            {/* Cidade Padrão */}
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700 dark:text-zinc-300 block">Cidade</label>
              <input type="text" name="cidade" value={formData.cidade} onChange={handleChange} 
                className="w-full px-3 py-2 text-sm bg-slate-100 dark:bg-zinc-900 border border-slate-200 dark:border-zinc-800 rounded-lg text-slate-500 dark:text-zinc-500 cursor-not-allowed" disabled />
            </div>
          </div>

          {/* BOTÃO SUBMIT ANIMAÇÃO SUAVE */}
          <div className="flex justify-end pt-4 border-t border-slate-100 dark:border-zinc-800">
            <button type="submit" 
              className="px-5 py-2 text-sm font-medium text-white bg-emerald-600 hover:bg-emerald-500 active:scale-95 rounded-lg shadow-sm transition-all duration-150">
              Salvar Registro
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
