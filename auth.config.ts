// ./auth.config.ts
/*
Este arquivo não deve conter nenhuma dependência de banco de dados ou criptografia Node.js.
*/
import type { NextAuthConfig } from "next-auth";

export const authConfig: NextAuthConfig = {
  session: {
    strategy: "jwt",
  },
  pages: {
    signIn: "/login",
  },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.role = user.role ?? "";
        token.id = user.id ?? "";
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.role = token.role ?? "";
        session.user.id = token.id ?? "";
      }
      return session;
    },
  },
  providers: [], // Fica vazio aqui por compatibilidade com o Edge
};
