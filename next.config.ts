import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Impede que o Next.js tente empacotar o driver nativo do PostgreSQL
  serverExternalPackages: ["@prisma/client", "pg"], 
};

export default nextConfig;
