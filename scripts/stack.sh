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
