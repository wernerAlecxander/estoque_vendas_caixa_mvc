import NextAuth, { AuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import bcrypt from "bcrypt";
import { pool } from "@/lib/db";

interface UsuarioBanco {
  id: string;
  nome: string;
  email: string;
  senha_hash: string;
  cargo: string;
}

export const authOptions: AuthOptions = {
  providers: [
    CredentialsProvider({
      name: "Credentials",
      credentials: {
        email: { label: "Email", type: "text" },
        senha: { label: "Senha", type: "password" }
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.senha) {
          throw new Error("Credenciais ausentes.");
        }

        const resultado = await pool.query<UsuarioBanco>(
          "SELECT * FROM usuarios WHERE email = $1",
          [credentials.email]
        );
        const usuario = resultado.rows[0];

        if (!usuario) {
          throw new Error("Usuário ou senha incorretos.");
        }

        const senhaValida = await bcrypt.compare(credentials.senha, usuario.senha_hash);
        if (!senhaValida) {
          throw new Error("Usuário ou senha incorretos.");
        }

        return {
          id: usuario.id.toString(),
          name: usuario.nome,
          email: usuario.email,
          role: usuario.cargo
        };
      }
    })
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.role = user.role;
        token.id = user.id;
      }
      return token;
    },
    async session({ session, token }) {
      if (token && session.user) {
        session.user.role = token.role;
        session.user.id = token.id;
      }
      return session;
    }
  },
  pages: {
    signIn: "/login"
  },
  secret: process.env.NEXTAUTH_SECRET
};
