# Typebot as a Service

Plataforma de automação de atendimento via WhatsApp para pequenas e médias empresas.

## Objetivo
Oferecer soluções padronizadas de atendimento automatizado através de mensalidade recorrente.

## Stack tecnológica
- Typebot
- Chatwoot
- WhatsApp Cloud API (Meta)
- Docker
- PostgreSQL
- Redis
- Nginx / Traefik

## Primeiro nicho
Clínicas de estética.

## Modelo comercial
- Taxa de implantação.
- Mensalidade recorrente.
- Suporte e manutenção.

## Meta financeira
R$ 20.000 de lucro líquido mensal.

## Rodando localmente
Pré-requisito: Docker + Docker Compose v2.

```bash
docker compose --env-file .env.local -f docker-compose.local.yml up -d
```

| Serviço | URL |
|---|---|
| Typebot Builder | http://localhost:8080 |
| Typebot Viewer | http://localhost:8081 |
| Chatwoot | http://localhost:3000 |
| Mailpit (e-mails/magic link) | http://localhost:8025 |

Parar: `docker compose --env-file .env.local -f docker-compose.local.yml down`
Resetar tudo (apaga dados): adicione `-v` ao `down`.
