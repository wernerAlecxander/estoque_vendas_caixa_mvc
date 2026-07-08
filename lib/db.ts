/*
import { Pool } from 'pg';
export const pool: Pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});
*/

// Importa a classe principal do pacote oficial do Prisma para gerenciar as operações do banco de dados.
import { PrismaClient } from '@prisma/client';

//globalThis: Objeto global padrão do JavaScript (funciona no Node.js e no navegador).
//: Um truque do TypeScript. O objeto global padrão não sabe o que é prisma. Forçamos o TypeScript a aceitar que esse objeto global pode conter uma propriedade chamada prisma tipada corretamente.
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

//Cria a constante prisma que você importará nos outros arquivos do projeto.
//globalForPrisma.prisma || ...: Verifica se já existe uma instância salva no escopo global.
//Se já existir, ele a reutiliza. Se não existir (como na primeira vez que o app roda), ele executa new PrismaClient() para abrir a conexão
export const prisma = globalForPrisma.prisma || new PrismaClient();

//process.env.NODE_ENV !== 'production': Avalia se o projeto está rodando em ambiente de desenvolvimento.
//Em produção isso não é necessário, pois o código roda continuamente sem recarregamentos automáticos.
//Se estiver em desenvolvimento, a instância recém-criada é salva dentro do objeto global. No próximo Hot Reload, o código lerá essa mesma instância em vez de gerar novas conexões desnecessárias.
if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
