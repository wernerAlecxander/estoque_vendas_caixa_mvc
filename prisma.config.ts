import "dotenv/config";
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  // Caminho do seu arquivo de esquema
  schema: "prisma/schema.prisma",
  
  // Onde as migrações serão salvas
  migrations: {
    path: "prisma/migrations",
  },
  
  // Configuração central da URL do banco de dados para a CLI
  datasource: {
    url: env("DATABASE_URL"),
  },
});
