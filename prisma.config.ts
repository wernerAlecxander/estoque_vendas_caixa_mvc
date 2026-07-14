// prisma.config.ts
import { existsSync } from "node:fs";
import { config } from "dotenv";
import { defineConfig, env } from "prisma/config";

// 1. Carrega o .env.local apenas se ele existir (útil para desenvolvimento local/Codespaces)
// Se o Docker Compose já injetou a DATABASE_URL na máquina, o process.env manterá a prioridade
if (existsSync(".env.local")) {
  config({ path: ".env.local" });
} else {
  config(); // Fallback para .env padrão se aplicável
}

export default defineConfig({
  schema: "./prisma/schema.prisma",
  migrations: {
    path: "./prisma/migrations",
    // [NOVO NO PRISMA 7]: O script de seed deve ser declarado diretamente aqui!
    seed: "tsx prisma/seed.ts", 
  },
  datasource: {
    // Captura com segurança a variável resolvida pelo dotenv ou Docker
    url: env("DATABASE_URL"), 
  },
});
