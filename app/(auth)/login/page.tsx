/*
SEQUENCIA DE FLUXO DE DADOS
 [Formulário de Login] 
       │ (1. Usuário clica em Entrar)
       ▼
[app/(auth)/login/action.ts] 
       │ (2. Server Action recebe FormData e chama signIn())
       ▼
[./auth.ts (Authorize)] 
       │ (3. Consulta o Prisma Client e valida com o Bcrypt)
       ▼
[./auth.config.ts (JWT / Session)] 
       │ (4. Callbacks gravam o 'role' no cookie criptografado)
       ▼
[./middleware.ts] 
         (5. Lê o auth.config.ts levíssimo, valida e libera a rota "/")
*/
"use client";

import { useActionState } from "react";
import { autenticarUsuario } from "./action";

export default function LoginPage() {
  // useActionState gerencia o estado do formulário (mensagens de erro do CustomAuthError)
  const [errorMessage, dispatch, isPending] = useActionState(
    autenticarUsuario,
    undefined
  );

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h2 style={styles.title}>Acessar o Sistema</h2>
        
        <form action={dispatch} style={styles.form}>
          <div style={styles.inputGroup}>
            <label htmlFor="email">E-mail</label>
            <input 
              id="email" 
              name="email" 
              type="email" 
              required 
              style={styles.input} 
            />
          </div>

          <div style={styles.inputGroup}>
            <label htmlFor="senha">Senha</label>
            <input 
              id="senha" 
              name="senha" 
              type="password" 
              required 
              style={styles.input} 
            />
          </div>

          {/* Exibe a mensagem exata gerada pelo seu CustomAuthError */}
          {errorMessage && (
            <p style={styles.errorText}>{errorMessage}</p>
          )}

          <button 
            type="submit" 
            disabled={isPending} 
            style={styles.button}
          >
            {isPending ? "Autenticando..." : "Entrar"}
          </button>
        </form>
      </div>
    </div>
  );
}

// Estilos inline básicos para a tela não ficar totalmente desalinhada
//cores do backgroundColor para testar (#2F4F4F, #1F3A5A, #4A5665, #384B5B)
const styles = {
  container: { display: "flex", height: "100vh", alignItems: "center", justifyContent: "center", backgroundColor: "#2F4F4F" },
  card: { padding: "2rem", backgroundColor: "#fff", borderRadius: "8px", boxShadow: "0 4px 6px rgba(0,0,0,0.1)", width: "100%", maxWidth: "400px" },
  title: { textAlign: "center" as const, marginBottom: "1.5rem", color: "#1f2937" },
  form: { display: "flex", flexDirection: "column" as const, gap: "1rem" },
  inputGroup: { display: "flex", flexDirection: "column" as const, gap: "0.5rem" },
  input: { padding: "0.75rem", borderRadius: "4px", border: "1px solid #d1d5db" },
  button: { padding: "0.75rem", backgroundColor: "#2563eb", color: "#fff", border: "none", borderRadius: "4px", cursor: "pointer", fontWeight: "bold" as const },
  errorText: { color: "#dc2626", fontSize: "0.875rem", textAlign: "center" as const, margin: "0" }
};

/*
ROTEIRO COMPLETO DA SEQUÊNCIA PERCORRIDA
1. Interface (app/(auth)/login/page.tsx)O usuário preenche e-mail e senha. O formulário HTML empacota os dados e os envia via Server Action ao clicar no botão.2. Server Action (app/(auth)/login/action.ts)Roda 100% no servidor. Ela captura os dados limpos e invoca a função signIn("credentials", { email, senha }).3. Provedor de Autenticação (./auth.ts)A função authorize é disparada. É aqui que entra o Prisma (para buscar no Postgres/MySQL) e o Bcrypt (para descriptografar). Se os dados forem válidos, ela retorna o objeto do usuário com o role.4. Estrutura Base (./auth.config.ts)Assim que o usuário é validado, os callbacks entram em ação. O jwt() pega o cargo e insere no cookie do navegador de forma criptografada. O session() deixa esse dado disponível para os componentes visuais.5. O Guardião de Rotas (./middleware.ts)Nas próximas páginas que o usuário acessar, o Middleware lerá apenas o arquivo leve auth.config.ts para verificar o cookie. Como ele não toca mais no auth.ts, o banco de dados não é sobrecarregado a cada clique de navegação.
*/