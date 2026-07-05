if (process.env.CODESPACE_NAME) {
  const port = process.env.PORT || '3100';
  process.env.NEXTAUTH_URL = `https://${process.env.CODESPACE_NAME}-${port}.app.github.dev`;
}//URL correta do Codespaces antes de inicializar o servidor. Caso esteja rodando localmente, a variável de ambiente NEXTAUTH_URL deve ser definida no arquivo .env.local

import NextAuth, { CredentialsSignin } from "next-auth";
import Credentials from "next-auth/providers/credentials"; //provedor que permite autenticar usuários usando formulários próprios (email e senha) em vez de redes sociais
import bcrypt from "bcryptjs";
import { prisma } from "@/lib/prisma"; // Importa o Prisma isolado do passo 1
import { authConfig } from "./auth.config";

class CustomAuthError extends CredentialsSignin {
  constructor(mensagem: string) {
    super();
    this.code = mensagem;
  }
}

export const { handlers, auth, signIn, signOut } = NextAuth({
  ...authConfig,
  providers: [
    Credentials({
      name: "Credentials",
      credentials: {
        email: { label: "Email", type: "text" },
        senha: { label: "Senha", type: "password" }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.senha) {
          throw new CustomAuthError("Credenciais ausentes.");
        }

        const usuario = await prisma.usuarios.findUnique({
          where: { email: credentials.email as string }
        });

        if (!usuario) {
          throw new CustomAuthError("Usuário ou senha incorretos.");
        }

        const senhaValida = await bcrypt.compare(credentials.senha as string, usuario.senha_hash);
        if (!senhaValida) {
          throw new CustomAuthError("Usuário ou senha incorretos.");
        }

        return {
          id: usuario.id.toString(),
          name: usuario.nome,
          email: usuario.email,
          role: usuario.cargo_usuario 
        };
      }
    })
  ]
});
