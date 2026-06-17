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

/* EXEMPLO PARA IMPORTAR O PRISMA NAS PAGES.TSX
// Opção 1: Import padrão
import prisma from '@/lib/prisma'

// Opção 2: Import nomeado
import { prisma } from '@/lib/prisma'
*/