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
