FROM node:22.19.0-alpine
WORKDIR /app

# 1. Ativa o corepack antes de copiar arquivos para aproveitar o cache do Docker
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

# 2. Configura a variável de ambiente para o pnpm usar uma pasta de cache local
#NÃO ESQUECER DE RODAR PNPM INSTALL TODA VEZ QUE ALTERAR ALGUMA COISA.
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# 3. Copia APENAS os manifestos primeiro
COPY package.json pnpm-lock.yaml* ./

# 4. Melhores Práticas: Instala as dependências usando cache nativo do Docker BuildKit
# Isso evita baixar tudo de novo se o lockfile não mudou
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --no-frozen-lockfile
# rode este comando abaixo se precisar abrir uma janela no linux (Ubuntu/Debian).
# RUN apt-get update && apt-get install -y xdg-utils lynx --no-install-recommends && rm -rf /var/lib/apt/lists/*
# rode este comando abaixo se precisar abrir uma janela no linux (Ubuntu/Debian).
# RUN apk add --no-cache xdg-utils


# 5. Copia o restante do código (como o código muda muito, fica por último)
COPY . .

EXPOSE 3100

CMD ["pnpm", "run", "dev"]

# Para rodar no codespace quando quiser abrir o PRISMA STUDIO no browser:
# docker compose exec next-app pnpm prisma studio --port $PRISMA_STUDIO_PORT --browser none docker compose exec -d next-app pnpm prisma studio --port $PRISMA_STUDIO_PORT --browser none



