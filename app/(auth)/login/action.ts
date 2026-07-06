// Para conectar o formulário visual (page.tsx) com o seu arquivo auth.ts de forma segura
"use server";

import { signIn } from "@/auth";
import { AuthError } from "next-auth";

export async function autenticarUsuario(prevState: string | undefined, formData: FormData) {
  try {
    const email = formData.get("email");
    const senha = formData.get("senha");

    // Aciona a função signIn passando as credenciais para o método authorize
    await signIn("credentials", {
      email,
      senha,
      redirectTo: "/", // Para onde o usuário vai se o login der certo
    });
  } catch (error) {
    if (error instanceof AuthError) {
      // Captura o código de erro customizado que você injetou na classe CustomAuthError
      return error.cause?.err?.message || "Usuário ou senha incorretos.";
    }
    // IMPORTANTE: O Next.js usa redirecionamentos jogando erros internos. 
    // Se não relançar o erro, o redirecionamento da página após o login quebra.
    throw error;
  }
}
