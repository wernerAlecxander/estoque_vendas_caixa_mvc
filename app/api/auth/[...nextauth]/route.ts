// exporta os seletores que processam as requisições HTTP do arquivo (./auth.ts)

export const dynamic = "force-dynamic";//força o Next.js a tratar essa rota como dinâmica, garantindo que o servidor sempre processe as tentativas de login em tempo real, sem tentar "salvar em cache" (fazer build estático) de uma rota de autenticação.

import { handlers } from "@/auth"; // Puxa os handlers do ./auth.ts da raiz
export const { GET, POST } = handlers;
