# Alterado para a mesma versão do seu ambiente local
FROM node:22.19.0-alpine
WORKDIR /app

# Copia os manifestos de pacotes
COPY package.json pnpm-lock.yaml* ./

# Ativa o corepack e prepara o pnpm
# Garante a versão exata exigida pelo package.json
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# Instala todas as dependências necessárias para desenvolvimento e build
RUN pnpm install

# roda o prisma para mapear o banco de dados e criar o schema.prisma
#RUN pnpm prisma generate

# Copia o restante do código da sua máquina para o container
COPY . .

# Expõe a porta 3100 para acesso externo
EXPOSE 3100

# CORRIGIDO: Executa usando o pnpm em vez do npm
CMD ["pnpm", "run", "dev"]
