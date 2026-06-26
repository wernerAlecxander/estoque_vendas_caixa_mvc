// exporta os seletores que processam as requisições HTTP do arquivo (./auth.ts)

export const dynamic = "force-dynamic";

import { handlers } from "@/auth"; // Puxa os handlers do ./auth.ts da raiz
export const { GET, POST } = handlers;
