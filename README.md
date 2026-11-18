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

### Pré-requisitos

- Docker
- Docker Compose

### Iniciar os serviços

Na raiz do projeto, execute:

```bash
docker compose --env-file .env -f docker-compose.yml up -d --wait
```

### Acessos locais

| Serviço | URL |
|---|---|
| Typebot Builder | http://localhost:8080 |
| Typebot Viewer | http://localhost:8081 |
| Chatwoot | http://localhost:3000 |
| Mailpit | http://localhost:8025 |

### Verificar os serviços

```bash
./infrastructure/status.sh
```

### Consultar logs

```bash
docker compose --env-file .env -f docker-compose.yml logs -f
```

### Parar os serviços

```bash
docker compose --env-file .env -f docker-compose.yml down
```

**Atenção:** não utilize `down -v` para a parada normal, pois essa opção remove os volumes e pode apagar os dados persistidos.

## Documentação

- `docs/business-model.md` — Modelo de negócio.
- `docs/infrastructure.md` — Infraestrutura.
- `docs/pricing.md` — Precificação.
- `docs/sales-strategy.md` — Estratégia comercial.
- `docs/INTEGRACAO-TYPEBOT-CHATWOOT.md` — Integração entre Typebot e Chatwoot.

## Próxima etapa

Concluir a integração local entre Typebot, Chatwoot e Mailpit antes de iniciar a integração com a WhatsApp Cloud API.