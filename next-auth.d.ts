//ARQUIVO DE DECLARAÇÃO DE TIPOS (USER, ROLE e ID)

import { DefaultSession, DefaultUser } from "next-auth";
// IMPORTANTE: Importar o JWT explicitamente garante a extensão correta na v5
import "next-auth/jwt"; 

declare module "next-auth" {
  interface Session {
    user: {
      id: string;
      role: string;
    } & DefaultSession["user"];
  }

  interface User extends DefaultUser {
    role?: string;
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    id?: string;
    role?: string;
  }
}
