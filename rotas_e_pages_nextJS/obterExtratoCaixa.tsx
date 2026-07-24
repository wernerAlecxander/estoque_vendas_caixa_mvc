//import { PrismaClient } from '@prisma/client'
import { PrismaClient } from "../prisma/generated/client"
const prisma = new PrismaClient()

async function obterExtratoCaixa() {
  const lancamentos = await prisma.fluxo_caixa.findMany({
    include: {
      estoque_objetos_duraveis: true,  // Traz o item durável associado se houver
      estoque_objetos_genericos: true, // Traz o item genérico associado se houver
      usuario_caixa: {
        select: { nome: true, email: true } // Protege dados sensíveis trazendo apenas o necessário
      }
    },
    orderBy: {
      id: 'desc' // Graças ao UUIDv7, ordenar pelo ID ordena cronologicamente por padrão!
    }
  })
  
  return lancamentos
}

export default obterExtratoCaixa