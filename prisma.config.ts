import { config } from "dotenv";
// Força o Prisma CLI a ler o arquivo local com endereço localhost
if (require("fs").existsSync(".env.local")){
config({ path: ".env.local" });
}
config({ path: ".env" });
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  // Caminho do seu arquivo de esquema
  schema: "prisma/schema.prisma",
  
  // Onde as migrações serão salvas
  migrations: {
    path: "prisma/migrations",
    seed: "pnpm dlx tsx prisma/seed.ts",
  },
  
  // Configuração central da URL do banco de dados para a CLI
  datasource: {
    url: env("DATABASE_URL"),
  },
});
