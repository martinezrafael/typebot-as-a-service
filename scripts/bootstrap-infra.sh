#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=========================================="
echo " TYPEBOT AS A SERVICE"
echo " INSTALADOR DE INFRAESTRUTURA"
echo "=========================================="

for cmd in docker openssl; do
  command -v "$cmd" >/dev/null || {
    echo "ERRO: $cmd não está instalado."
    exit 1
  }
done

docker compose version >/dev/null

BACKUP=".backup/$(date +%Y%m%d-%H%M%S)"
FILES=(
  docker-compose.yml
  docker-compose.local.yml
  .env.local
  .env.production.example
  .gitignore
  scripts/stack.sh
  infrastructure/docker/README.md
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    mkdir -p "$BACKUP/$(dirname "$file")"
    cp -a "$file" "$BACKUP/$file"
  fi
done

echo "Backup realizado em: $BACKUP"

mkdir -p scripts infrastructure/docker

# ==========================================
# AMBIENTE LOCAL
# ==========================================

cat > docker-compose.local.yml <<'YAML'
name: taas-local

services:

  typebot-db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: typebot
      POSTGRES_USER: typebot
      POSTGRES_PASSWORD: ${POSTGRES_TYPEBOT_PASSWORD:?Configure a senha}
    volumes:
      - typebot_db_local:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U typebot -d typebot"]
      interval: 10s
      timeout: 5s
      retries: 10

  typebot-builder:
    image: baptistearno/typebot-builder:${TYPEBOT_VERSION:-latest}
    restart: unless-stopped
    depends_on:
      typebot-db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://typebot:${POSTGRES_TYPEBOT_PASSWORD}@typebot-db:5432/typebot
      ENCRYPTION_SECRET: ${ENCRYPTION_SECRET}
      NEXTAUTH_URL: http://localhost:8080
      NEXT_PUBLIC_VIEWER_URL: http://localhost:8081
      ADMIN_EMAIL: ${ADMIN_EMAIL}
      NODE_OPTIONS: --no-node-snapshot
    ports:
      - "127.0.0.1:8080:3000"

  typebot-viewer:
    image: baptistearno/typebot-viewer:${TYPEBOT_VERSION:-latest}
    restart: unless-stopped
    depends_on:
      typebot-db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://typebot:${POSTGRES_TYPEBOT_PASSWORD}@typebot-db:5432/typebot
      ENCRYPTION_SECRET: ${ENCRYPTION_SECRET}
      NEXTAUTH_URL: http://localhost:8080
      NEXT_PUBLIC_VIEWER_URL: http://localhost:8081
      NODE_OPTIONS: --no-node-snapshot
    ports:
      - "127.0.0.1:8081:3000"

  chatwoot-db:
    image: pgvector/pgvector:pg16
    restart: unless-stopped
    environment:
      POSTGRES_DB: chatwoot
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_CHATWOOT_PASSWORD}
    volumes:
      - chatwoot_db_local:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d chatwoot"]
      interval: 10s
      timeout: 5s
      retries: 10

  chatwoot-redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: >
      sh -c 'redis-server --appendonly yes --requirepass "$$REDIS_PASSWORD"'
    environment:
      REDIS_PASSWORD: ${REDIS_PASSWORD}
    volumes:
      - chatwoot_redis_local:/data
    healthcheck:
      test: ["CMD-SHELL", "redis-cli -a \"$$REDIS_PASSWORD\" ping | grep -q PONG"]
      interval: 10s
      timeout: 5s
      retries: 10

  chatwoot:
    image: chatwoot/chatwoot:${CHATWOOT_VERSION:-latest}
    restart: unless-stopped
    entrypoint: docker/entrypoints/rails.sh
    command: ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
    depends_on:
      chatwoot-db:
        condition: service_healthy
      chatwoot-redis:
        condition: service_healthy
    environment:
      RAILS_ENV: production
      NODE_ENV: production
      INSTALLATION_ENV: docker
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      FRONTEND_URL: http://localhost:3000
      POSTGRES_HOST: chatwoot-db
      POSTGRES_PORT: 5432
      POSTGRES_DATABASE: chatwoot
      POSTGRES_USERNAME: postgres
      POSTGRES_PASSWORD: ${POSTGRES_CHATWOOT_PASSWORD}
      REDIS_URL: redis://:${REDIS_PASSWORD}@chatwoot-redis:6379
      ACTIVE_STORAGE_SERVICE: local
      SMTP_ADDRESS: mailpit
      SMTP_PORT: 1025
      SMTP_AUTHENTICATION: none
    volumes:
      - chatwoot_storage_local:/app/storage
    ports:
      - "127.0.0.1:3000:3000"

  chatwoot-worker:
    image: chatwoot/chatwoot:${CHATWOOT_VERSION:-latest}
    restart: unless-stopped
    entrypoint: docker/entrypoints/rails.sh
    command: ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]
    depends_on:
      chatwoot-db:
        condition: service_healthy
      chatwoot-redis:
        condition: service_healthy
    environment:
      RAILS_ENV: production
      NODE_ENV: production
      INSTALLATION_ENV: docker
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      POSTGRES_HOST: chatwoot-db
      POSTGRES_PORT: 5432
      POSTGRES_DATABASE: chatwoot
      POSTGRES_USERNAME: postgres
      POSTGRES_PASSWORD: ${POSTGRES_CHATWOOT_PASSWORD}
      REDIS_URL: redis://:${REDIS_PASSWORD}@chatwoot-redis:6379
      ACTIVE_STORAGE_SERVICE: local
    volumes:
      - chatwoot_storage_local:/app/storage

  mailpit:
    image: axllent/mailpit:latest
    restart: unless-stopped
    ports:
      - "127.0.0.1:8025:8025"

volumes:
  typebot_db_local:
  chatwoot_db_local:
  chatwoot_redis_local:
  chatwoot_storage_local:
YAML

# ==========================================
# AMBIENTE DE PRODUÇÃO
# ==========================================

cat > docker-compose.yml <<'YAML'
name: taas-production

services:

  traefik:
    image: traefik:v3.6
    restart: unless-stopped
    command:
      - --providers.docker=true
      - --providers.docker.exposedbydefault=false
      - --providers.docker.network=taas_proxy
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --entrypoints.web.http.redirections.entrypoint.to=websecure
      - --entrypoints.web.http.redirections.entrypoint.scheme=https
      - --certificatesresolvers.le.acme.email=${ACME_EMAIL}
      - --certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.le.acme.httpchallenge.entrypoint=web
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_certs:/letsencrypt
    networks:
      - proxy

  typebot-db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: typebot
      POSTGRES_USER: typebot
      POSTGRES_PASSWORD: ${POSTGRES_TYPEBOT_PASSWORD:?Configure a senha}
    volumes:
      - typebot_db:/var/lib/postgresql/data
    networks:
      - data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U typebot -d typebot"]
      interval: 10s
      timeout: 5s
      retries: 10

  typebot-builder:
    image: baptistearno/typebot-builder:${TYPEBOT_VERSION:-latest}
    restart: unless-stopped
    depends_on:
      typebot-db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://typebot:${POSTGRES_TYPEBOT_PASSWORD}@typebot-db:5432/typebot
      ENCRYPTION_SECRET: ${ENCRYPTION_SECRET}
      NEXTAUTH_URL: https://${TYPEBOT_DOMAIN}
      NEXT_PUBLIC_VIEWER_URL: https://${VIEWER_DOMAIN}
      ADMIN_EMAIL: ${ADMIN_EMAIL}
      NODE_OPTIONS: --no-node-snapshot
    networks:
      - proxy
      - data
    labels:
      - traefik.enable=true
      - traefik.docker.network=taas_proxy
      - traefik.http.routers.builder.rule=Host(`${TYPEBOT_DOMAIN}`)
      - traefik.http.routers.builder.entrypoints=websecure
      - traefik.http.routers.builder.tls.certresolver=le
      - traefik.http.services.builder.loadbalancer.server.port=3000

  typebot-viewer:
    image: baptistearno/typebot-viewer:${TYPEBOT_VERSION:-latest}
    restart: unless-stopped
    depends_on:
      typebot-db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql://typebot:${POSTGRES_TYPEBOT_PASSWORD}@typebot-db:5432/typebot
      ENCRYPTION_SECRET: ${ENCRYPTION_SECRET}
      NEXTAUTH_URL: https://${TYPEBOT_DOMAIN}
      NEXT_PUBLIC_VIEWER_URL: https://${VIEWER_DOMAIN}
      NODE_OPTIONS: --no-node-snapshot
    networks:
      - proxy
      - data
    labels:
      - traefik.enable=true
      - traefik.docker.network=taas_proxy
      - traefik.http.routers.viewer.rule=Host(`${VIEWER_DOMAIN}`)
      - traefik.http.routers.viewer.entrypoints=websecure
      - traefik.http.routers.viewer.tls.certresolver=le
      - traefik.http.services.viewer.loadbalancer.server.port=3000

  chatwoot-db:
    image: pgvector/pgvector:pg16
    restart: unless-stopped
    environment:
      POSTGRES_DB: chatwoot
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_CHATWOOT_PASSWORD:?Configure a senha}
    volumes:
      - chatwoot_db:/var/lib/postgresql/data
    networks:
      - data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d chatwoot"]
      interval: 10s
      timeout: 5s
      retries: 10

  chatwoot-redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: >
      sh -c 'redis-server --appendonly yes --requirepass "$$REDIS_PASSWORD"'
    environment:
      REDIS_PASSWORD: ${REDIS_PASSWORD}
    volumes:
      - chatwoot_redis:/data
    networks:
      - data
    healthcheck:
      test: ["CMD-SHELL", "redis-cli -a \"$$REDIS_PASSWORD\" ping | grep -q PONG"]
      interval: 10s
      timeout: 5s
      retries: 10

  chatwoot:
    image: chatwoot/chatwoot:${CHATWOOT_VERSION:-latest}
    restart: unless-stopped
    entrypoint: docker/entrypoints/rails.sh
    command: ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
    depends_on:
      chatwoot-db:
        condition: service_healthy
      chatwoot-redis:
        condition: service_healthy
    environment:
      RAILS_ENV: production
      NODE_ENV: production
      INSTALLATION_ENV: docker
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      FRONTEND_URL: https://${CHATWOOT_DOMAIN}
      FORCE_SSL: "true"
      ENABLE_ACCOUNT_SIGNUP: "false"
      POSTGRES_HOST: chatwoot-db
      POSTGRES_PORT: 5432
      POSTGRES_DATABASE: chatwoot
      POSTGRES_USERNAME: postgres
      POSTGRES_PASSWORD: ${POSTGRES_CHATWOOT_PASSWORD}
      REDIS_URL: redis://:${REDIS_PASSWORD}@chatwoot-redis:6379
      ACTIVE_STORAGE_SERVICE: local
    volumes:
      - chatwoot_storage:/app/storage
    networks:
      - proxy
      - data
    labels:
      - traefik.enable=true
      - traefik.docker.network=taas_proxy
      - traefik.http.routers.chatwoot.rule=Host(`${CHATWOOT_DOMAIN}`)
      - traefik.http.routers.chatwoot.entrypoints=websecure
      - traefik.http.routers.chatwoot.tls.certresolver=le
      - traefik.http.services.chatwoot.loadbalancer.server.port=3000

  chatwoot-worker:
    image: chatwoot/chatwoot:${CHATWOOT_VERSION:-latest}
    restart: unless-stopped
    entrypoint: docker/entrypoints/rails.sh
    command: ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]
    depends_on:
      chatwoot-db:
        condition: service_healthy
      chatwoot-redis:
        condition: service_healthy
    environment:
      RAILS_ENV: production
      NODE_ENV: production
      INSTALLATION_ENV: docker
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      POSTGRES_HOST: chatwoot-db
      POSTGRES_PORT: 5432
      POSTGRES_DATABASE: chatwoot
      POSTGRES_USERNAME: postgres
      POSTGRES_PASSWORD: ${POSTGRES_CHATWOOT_PASSWORD}
      REDIS_URL: redis://:${REDIS_PASSWORD}@chatwoot-redis:6379
      ACTIVE_STORAGE_SERVICE: local
    volumes:
      - chatwoot_storage:/app/storage
    networks:
      - data

networks:
  proxy:
    name: taas_proxy
  data:
    name: taas_data
    internal: true

volumes:
  traefik_certs:
  typebot_db:
  chatwoot_db:
  chatwoot_redis:
  chatwoot_storage:
YAML

# ==========================================
# VARIÁVEIS LOCAIS
# ==========================================

if [ ! -f .env.local ]; then
  cat > .env.local <<EOF
TYPEBOT_VERSION=latest
CHATWOOT_VERSION=latest
POSTGRES_TYPEBOT_PASSWORD=$(openssl rand -hex 24)
POSTGRES_CHATWOOT_PASSWORD=$(openssl rand -hex 24)
REDIS_PASSWORD=$(openssl rand -hex 24)
ENCRYPTION_SECRET=$(openssl rand -hex 16)
SECRET_KEY_BASE=$(openssl rand -hex 64)
ADMIN_EMAIL=admin@localhost
EOF
  chmod 600 .env.local
else
  echo ".env.local existente preservado."
fi

# ==========================================
# MODELO DE PRODUÇÃO
# ==========================================

cat > .env.production.example <<'ENV'
ACME_EMAIL=
TYPEBOT_DOMAIN=bot.exemplo.com
VIEWER_DOMAIN=viewer.exemplo.com
CHATWOOT_DOMAIN=chat.exemplo.com
ADMIN_EMAIL=

TYPEBOT_VERSION=latest
CHATWOOT_VERSION=latest

POSTGRES_TYPEBOT_PASSWORD=
POSTGRES_CHATWOOT_PASSWORD=
REDIS_PASSWORD=
ENCRYPTION_SECRET=
SECRET_KEY_BASE=
ENV

# ==========================================
# GITIGNORE
# ==========================================

touch .gitignore

for entry in \
  '.env.local' \
  '.env.production' \
  '.env' \
  '.backup/' \
  'backups/' \
  'secrets/' \
  '*.pem' \
  '*.key' \
  '*.log'
do
  grep -Fxq "$entry" .gitignore || echo "$entry" >> .gitignore
done

# ==========================================
# GERENCIADOR
# ==========================================

cat > scripts/stack.sh <<'STACK'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

LOCAL=(docker compose --env-file .env.local -f docker-compose.local.yml)
PROD=(docker compose --env-file .env.production -f docker-compose.yml)

case "${1:-help}" in

  local-validate)
    "${LOCAL[@]}" config --quiet
    echo "Configuração local válida."
    ;;

  local-up)
    "${LOCAL[@]}" config --quiet
    "${LOCAL[@]}" up -d typebot-db chatwoot-db chatwoot-redis
    "${LOCAL[@]}" run --rm --no-deps chatwoot bundle exec rails db:chatwoot_prepare
    "${LOCAL[@]}" up -d
    echo "Ambiente local iniciado."
    ;;

  local-down)
    "${LOCAL[@]}" down
    ;;

  local-status)
    "${LOCAL[@]}" ps
    ;;

  local-logs)
    "${LOCAL[@]}" logs -f --tail=100
    ;;

  prod-init)
    if [ -f .env.production ]; then
      echo ".env.production já existe. Não será sobrescrito."
      exit 1
    fi

    read -rp "Domínio Builder: " BOT
    read -rp "Domínio Viewer: " VIEWER
    read -rp "Domínio Chatwoot: " CHAT
    read -rp "E-mail ACME: " EMAIL
    read -rp "E-mail administrador: " ADMIN

    cp .env.production.example .env.production

    sed -i \
      -e "s|^ACME_EMAIL=.*|ACME_EMAIL=$EMAIL|" \
      -e "s|^TYPEBOT_DOMAIN=.*|TYPEBOT_DOMAIN=$BOT|" \
      -e "s|^VIEWER_DOMAIN=.*|VIEWER_DOMAIN=$VIEWER|" \
      -e "s|^CHATWOOT_DOMAIN=.*|CHATWOOT_DOMAIN=$CHAT|" \
      -e "s|^ADMIN_EMAIL=.*|ADMIN_EMAIL=$ADMIN|" \
      .env.production

    {
      echo "POSTGRES_TYPEBOT_PASSWORD=$(openssl rand -hex 24)"
      echo "POSTGRES_CHATWOOT_PASSWORD=$(openssl rand -hex 24)"
      echo "REDIS_PASSWORD=$(openssl rand -hex 24)"
      echo "ENCRYPTION_SECRET=$(openssl rand -hex 16)"
      echo "SECRET_KEY_BASE=$(openssl rand -hex 64)"
    } >> .env.production

    chmod 600 .env.production
    echo "Produção configurada. Configure SMTP e DNS antes da implantação."
    ;;

  prod-validate)
    test -f .env.production
    "${PROD[@]}" config --quiet
    echo "Configuração de produção válida."
    ;;

  prod-up)
    test -f .env.production
    "${PROD[@]}" config --quiet
    "${PROD[@]}" up -d typebot-db chatwoot-db chatwoot-redis
    "${PROD[@]}" run --rm --no-deps chatwoot bundle exec rails db:chatwoot_prepare
    "${PROD[@]}" up -d
    ;;

  prod-down)
    "${PROD[@]}" down
    ;;

  prod-status)
    "${PROD[@]}" ps
    ;;

  prod-logs)
    "${PROD[@]}" logs -f --tail=100
    ;;

  *)
    cat <<'HELP'
TYPEBOT AS A SERVICE

LOCAL:
  ./scripts/stack.sh local-validate
  ./scripts/stack.sh local-up
  ./scripts/stack.sh local-status
  ./scripts/stack.sh local-logs
  ./scripts/stack.sh local-down

PRODUÇÃO:
  ./scripts/stack.sh prod-init
  ./scripts/stack.sh prod-validate
  ./scripts/stack.sh prod-up
  ./scripts/stack.sh prod-status
  ./scripts/stack.sh prod-logs
  ./scripts/stack.sh prod-down

ATENÇÃO:
  down preserva os volumes.
  Nunca use down -v sem backup.
HELP
    ;;
esac
STACK

chmod +x scripts/stack.sh

# ==========================================
# DOCUMENTAÇÃO
# ==========================================

cat > infrastructure/docker/README.md <<'DOC'
# Infraestrutura Docker

## Desenvolvimento
docker-compose.local.yml

## Produção
docker-compose.yml

## Gerenciamento
Utilize scripts/stack.sh.

## Serviços
- Typebot Builder
- Typebot Viewer
- Chatwoot
- PostgreSQL
- Redis
- Traefik

## Segurança
- Bancos sem portas públicas.
- Segredos fora do Git.
- Volumes persistentes.
- HTTPS na produção.
- Backups externos obrigatórios.

Produção exige homologação das versões, SMTP, DNS,
firewall e política de backup.
DOC

# ==========================================
# VALIDAÇÃO
# ==========================================

echo ""
echo "Validando ambiente local..."

docker compose \
  --env-file .env.local \
  -f docker-compose.local.yml \
  config --quiet

echo "Compose local: OK"

echo ""
echo "Validando estrutura..."

bash -n scripts/stack.sh
test -s docker-compose.yml
test -s docker-compose.local.yml
test -s .env.local
test -x scripts/stack.sh

echo ""
echo "=========================================="
echo " INSTALAÇÃO DOS ARQUIVOS CONCLUÍDA"
echo "=========================================="
echo ""
echo "Para iniciar:"
echo "./scripts/stack.sh local-up"
echo ""
echo "Para verificar:"
echo "./scripts/stack.sh local-status"
echo ""
echo "Nenhum container foi iniciado automaticamente."
