import NextAuth from "next-auth"
import { PrismaAdapter } from "@auth/prisma-adapter"
import { prisma } from "@/lib/prisma" // Caminho para o seu arquivo lib/prisma.ts

export const { handlers, auth, signIn, signOut } = NextAuth({
  // Injeta o adaptador mapeado do Prisma 7
  adapter: PrismaAdapter(prisma),
  providers: [
    // Configure seus provedores aqui (Ex: Credentials, Google, GitHub, etc.)
  ],
  callbacks: {
    jwt({ token, user }) {
      if (user) token.id = user.id
      return token
    },
    session({ session, token }) {
      if (session.user) session.user.id = token.id as string
      return session
    },
  },
  session: { strategy: "jwt" },
})
