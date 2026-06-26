//CredentialsSignin: classe de erro nativa do NextAuth v5 especificamente para falhas no provedor de credenciais (login com e-mail e senha)
import NextAuth, { type NextAuthConfig, CredentialsSignin } from "next-auth";
//provedor de autenticação por credenciais (Credentials). Permite validar usuários usando dados salvos no seu próprio banco de dados, em vez de usar provedores sociais (como Google ou GitHub).
import Credentials from "next-auth/providers/credentials";
import bcrypt from "bcryptjs";
//cliente do Prisma ORM (PrismaClient), que é o responsável por fazer as consultas de banco de dados (neste caso, buscar o usuário pelo e-mail).
import { PrismaClient } from "@prisma/client";

// Evita abrir múltiplas conexões com o banco em ambiente de desenvolvimento
const prisma = globalThis.prismaGlobal ?? new PrismaClient();
if (process.env.NODE_ENV !== "production") globalThis.prismaGlobal = prisma;

declare global {
  var prismaGlobal: PrismaClient | undefined;
}

// Classe customizada para enviar a mensagem de erro exata para a tela de login
//classe CustomAuthError é uma "filha" de CredentialsSignin
class CustomAuthError extends CredentialsSignin {
  //inicializar o objeto quando usa a palavra new CustomAuthError("Sua mensagem")
  constructor(mensagem: string) {
    super();
    this.code = mensagem;
  }
}

//Exporta e tipa o objeto de configuração principal que o NextAuth vai ler.
export const authConfig: NextAuthConfig = {
  providers: [
    Credentials({
      name: "Credentials",
      credentials: {
        //define que acesso ao sistema será através de EMAIL e SENHA
        email: { label: "Email", type: "text" },
        senha: { label: "Senha", type: "password" }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.senha) {
          throw new CustomAuthError("Credenciais ausentes.");
        }

        // 1. Busca o usuário usando o Prisma Client (Substituindo o pool.query)
        const usuario = await prisma.usuarios.findUnique({
          where: { email: credentials.email as string }
        });

        if (!usuario) {
          throw new CustomAuthError("Usuário ou senha incorretos.");
        }

        // 2. Compara a senha usando o bcryptjs de forma assíncrona
        const senhaValida = await bcrypt.compare(credentials.senha as string, usuario.senha_hash);
        if (!senhaValida) {
          throw new CustomAuthError("Usuário ou senha incorretos.");
        }

        // 3. Retorna o usuário com os dados necessários (Totalmente tipado pelo arquivo d.ts)
        return {
          id: usuario.id.toString(),
          name: usuario.nome,
          email: usuario.email,
          role: usuario.cargo_usuario 
        };
      }
    })
  ],
  callbacks: {
    // Transmite os dados do usuário para o Token JWT
    async jwt({ token, user }) {
      if (user) {
        // Usamos uma string vazia ou asserção caso o dado não venha por algum motivo
        token.role = user.role ?? "";
        token.id = user.id ?? "";
      }
      return token;
    },
    // Transmite os dados do Token JWT para a Sessão ativa do Next.js
    async session({ session, token }) {
      if (token && session.user) {
        session.user.role = token.role ?? "";
        session.user.id = token.id ?? "";
      }
      return session;
    }
  },
  pages: {
    signIn: "/login"
  }
};

// Exportações obrigatórias do NextAuth v5 para as rotas e componentes
export const { handlers, auth, signIn, signOut } = NextAuth(authConfig);
