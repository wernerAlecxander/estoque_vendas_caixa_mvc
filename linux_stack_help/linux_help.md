# comando para instalar o nvm (node)
cat << 'EOF' >> ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

# comando para zerar (apagar) containers, vomules e redes
docker stop $(docker ps -a -q) 2>/dev/null; docker system prune -a --volumes -f; docker compose --env-file .env.local down -v --remove-orphans && docker compose up -d --build
