import { Pool } from 'pg'
import { PrismaClient } from '@prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined }

const prismaClientSingleton = () => {
  // 1. Cria a piscina de conexões nativa do PostgreSQL usando o driver 'pg'
  const pool = new Pool({ connectionString: process.env.DATABASE_URL })

  // 2. Cria o adaptador oficial exigido pelo Prisma 7
  const adapter = new PrismaPg(pool)

  // 3. Instancia o cliente passando o adaptador e mantendo as suas configurações de log
  return new PrismaClient({
    adapter, // <-- Obrigatório no Prisma 7
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  })
}

export const prisma = globalForPrisma.prisma ?? prismaClientSingleton()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

export default prisma


/* EXEMPLO PARA IMPORTAR O PRISMA NAS PAGES.TSX
// Opção 1: Import padrão
import prisma from '@/lib/prisma'

// Opção 2: Import nomeado
import { prisma } from '@/lib/prisma'
*/

//PRISMA.TS ANTIGO versão 6 (ATUALIZADO 25/06/2026)
/*
import { PrismaClient } from '@prisma/client'

const prismaClientSingleton = () => {
  return new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  })
}

// Sintaxe atualizada para evitar o erro visual no editor
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient | undefined }

export const prisma = globalForPrisma.prisma ?? prismaClientSingleton()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

export default prisma
*/