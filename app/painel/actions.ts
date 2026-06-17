'use server'

import prisma from '@/lib/prisma'
import { revalidatePath } from 'next/cache'

// 1. Ação para buscar os dados
export async function listarDadosDoBanco() {
  try {
    // Substitua "clientes" pelo nome de uma das suas 15 tabelas (em minúsculo)
    const dados = await prisma.clientes.findMany({
      take: 10, // Limita a 10 registros para o teste
    })
    return { success: true, data: dados }
  } catch (error) {
    console.error('Erro ao buscar dados:', error)
    return { success: false, error: 'Falha ao conectar ou buscar dados.' }
  }
}

// 2. Ação para criar um novo registro fictício
export async function criarRegistroTeste() {
  try {
    // Substitua "clientes" e os campos (ex: nome, email) pelos campos reais do seu schema
    await prisma.clientes.create({
      data: {
        nome: 'Cliente Teste Docker',
        email: `teste-${Date.now()}@email.com`,
      },
    })

    // Atualiza a página atual instantaneamente
    revalidatePath('/')
    return { success: true }
  } catch (error) {
    console.error('Erro ao inserir dados:', error)
    return { success: false, error: 'Falha ao inserir registro.' }
  }
}
