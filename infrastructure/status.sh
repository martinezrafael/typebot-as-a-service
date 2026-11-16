#!/usr/bin/env bash
set -a
[ -f .env ] && source .env
set +a

BUILDER_URL="${TYPEBOT_NEXTAUTH_URL:-http://localhost:8080}"
VIEWER_URL="${TYPEBOT_NEXT_PUBLIC_VIEWER_URL:-http://127.0.0.1:8081}"
CHATWOOT_URL="${CHATWOOT_FRONTEND_URL:-http://localhost:3000}"
MAILPIT_URL="http://${MAILPIT_BIND_IP:-127.0.0.1}:${MAILPIT_UI_PORT:-8025}"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║            🚀  TAAS LOCAL — SERVIÇOS INICIADOS               ║${NC}"
echo -e "${CYAN}${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
printf "${CYAN}${BOLD}║${NC}  ${BOLD}%-18s${NC} ${GREEN}%-39s${NC} ${CYAN}${BOLD}║${NC}\n" "Typebot Builder:" "$BUILDER_URL"
printf "${CYAN}${BOLD}║${NC}  ${BOLD}%-18s${NC} ${GREEN}%-39s${NC} ${CYAN}${BOLD}║${NC}\n" "Typebot Viewer:" "$VIEWER_URL"
printf "${CYAN}${BOLD}║${NC}  ${BOLD}%-18s${NC} ${GREEN}%-39s${NC} ${CYAN}${BOLD}║${NC}\n" "Chatwoot App:" "$CHATWOOT_URL"
printf "${CYAN}${BOLD}║${NC}  ${BOLD}%-18s${NC} ${GREEN}%-39s${NC} ${CYAN}${BOLD}║${NC}\n" "Mailpit (SMTP UI):" "$MAILPIT_URL"
echo -e "${CYAN}${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
printf "${CYAN}${BOLD}║${NC}  ${DIM}%-58s${NC} ${CYAN}${BOLD}║${NC}\n" "Admin Typebot: ${TYPEBOT_ADMIN_EMAIL:-admin@localhost}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$1" = "--open" ]; then
  echo -e "${YELLOW}⏳ Aguardando servidores web responderem antes de abrir o navegador...${NC}"
  for url in "$BUILDER_URL" "$CHATWOOT_URL" "$MAILPIT_URL"; do
    for i in $(seq 1 30); do
      if curl -s -o /dev/null "$url"; then
        break
      fi
      sleep 1
    done
  done

  echo -e "${GREEN}🌐 Abrindo abas no navegador...${NC}\n"
  xdg-open "$BUILDER_URL" >/dev/null 2>&1 &
  xdg-open "$CHATWOOT_URL" >/dev/null 2>&1 &
  xdg-open "$MAILPIT_URL" >/dev/null 2>&1 &
fi
