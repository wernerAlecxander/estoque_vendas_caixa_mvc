// Indica ao Next.js que este é um código que só roda no servidor. Isso impede que a lógica do banco de dados ou as credenciais fiquem expostas no navegador do usuário.
'use server';

//Importa a instância do Prisma Client, que é a ferramenta que conecta e faz as operações (ORM) no seu banco de dados PostgreSQL.
import { prisma } from '@/lib/db';
//Importa uma função do Next.js responsável por limpar o cache.
import { revalidatePath } from 'next/cache';
import { Timestamp } from 'next/dist/server/lib/cache-handlers/types';


// Representa o cliente completo salvo no PostgreSQL
export interface ClienteDoBanco {
  id: string;
  nome_cliente: string;
  cpf_cliente: string;
  endereco_cliente: string;
  bairro_cliente: string;
  cidade_cliente: string;
  telefone_cliente: string;
  data_nascimento: Date;
  email_cliente: string;
  data_cadastro: Date;
}

// Representa o cliente com os dados limitados pelo seu 'select'
export interface ClienteResumido {
  id: string;
  nome_cliente: string;
  cpf_cliente: string;
  email_cliente: string;
  cidade_cliente: string;
}

//Acessa a tabela clientes e deleta o registro cujo id corresponde ao UUIDv7 passado por parâmetro.
export async function deletarClienteDoBanco(id: string) {
  try {
    await prisma.clientes.delete({
      where: { id: id },
    });
    //  Avisa o Next.js que a página localizada na rota /teste-cliente/deletar foi alterada. Isso faz com que o Next.js busque os dados atualizados no banco de dados e redesenhe a tela instantaneamente (usando React Server Components).
    revalidatePath('/teste-cliente/deletar');
    //Retorna um objeto de sucesso para o componente que chamou a função, permitindo que você exiba uma mensagem de "Cliente deletado com sucesso" para o usuário.
    return { success: true };
    //Bloco de tratamento de erros. Se algo falhar (por exemplo, o cliente não existir ou o banco estiver fora do ar), o código não quebra a aplicação; ele captura o erro, registra no terminal do servidor e retorna um objeto informando que a operação falhou.
  } catch (error) {
    console.error("Erro ao deletar no Postgres:", error);
    return { success: false, error: "Não foi possível remover o registro." };
  }
}

export async function buscarClientesNoBanco(): Promise<ClienteResumido> {
  // Busca todos os clientes ordenados pelo ID (como é UUIDv7, já ordena por data de cadastro!)
  return await prisma.clientes.findMany({
    select: {
      id: true,
      nome_cliente: true,
      cpf_cliente: true,
      email_cliente: true,
      cidade_cliente: true,
    },
    orderBy: { id: 'desc' }
  });
}
