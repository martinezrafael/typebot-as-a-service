# Integrações

## 1. Typebot

**Responsabilidade:** Construção e execução dos fluxos automatizados.

Funcionalidades:
- Recepção de contatos.
- Exibição de menus.
- Coleta de informações.
- Controle de navegação.
- Execução de condições.
- Chamadas HTTP.
- Envio de dados para integrações externas.

Configurações necessárias:
- Criar workspace.
- Criar bot da clínica.
- Configurar variáveis.
- Construir os fluxos.
- Configurar integrações HTTP, quando necessárias.
- Publicar o bot.

---

## 2. WhatsApp Cloud API

**Responsabilidade:** Comunicação oficial pelo WhatsApp.

Funcionalidades:
- Receber mensagens dos clientes.
- Enviar mensagens.
- Receber eventos de mensagens.
- Disponibilizar informações do contato.
- Integrar o canal com a solução de automação e atendimento.

Configurações necessárias:
- Conta Meta Business.
- Aplicativo Meta.
- Número WhatsApp Business.
- Configuração da WhatsApp Cloud API.
- Configuração de webhooks.
- Permissões necessárias.
- Tokens de acesso.

**Observação:** Os tokens deverão ser armazenados em ambiente seguro, nunca diretamente neste documento.

---

## 3. Chatwoot

**Responsabilidade:** Gerenciamento do atendimento humano.

Funcionalidades:
- Receber conversas transferidas.
- Organizar contatos.
- Gerenciar conversas.
- Distribuir atendimentos entre agentes.
- Acompanhar o histórico.
- Encerrar conversas.

Configurações necessárias:
- Criar conta ou instância.
- Configurar organização.
- Criar Inbox.
- Configurar canal WhatsApp.
- Criar usuários e equipes.
- Definir regras de distribuição.
- Configurar integração com o fluxo automatizado.

---

## 4. Fluxo de integração

```text
             CLIENTE
                |
                v
             WHATSAPP
                |
                v
          CAMADA DE CANAL
                |
                v
             TYPEBOT
                |
       +--------+--------+
       |                 |
       v                 v
  AUTOMAÇÃO         ATENDIMENTO
       |              HUMANO
       |                 |
       v                 v
  INFORMAÇÕES        CHATWOOT
  AGENDAMENTO
  PROCEDIMENTOS
```

A conexão entre os sistemas deverá ser definida durante a configuração técnica, garantindo que o bot e os atendentes não respondam simultaneamente à mesma conversa.

---

## 5. Webhooks

Os webhooks poderão ser utilizados para:

- Enviar solicitações de agendamento.
- Registrar informações dos clientes.
- Encaminhar conversas para atendimento humano.
- Sincronizar informações entre sistemas.
- Atualizar status de atendimento.

Cada webhook deverá documentar:
- Endpoint.
- Método HTTP.
- Headers.
- Payload.
- Resposta esperada.
- Tratamento de erros.

---

## 6. Segurança

- Nunca armazenar tokens reais neste arquivo.
- Utilizar HTTPS nas integrações de produção.
- Armazenar credenciais em ambiente seguro.
- Restringir permissões de acesso.
- Evitar exposição de dados pessoais.
- Registrar erros sem armazenar informações sensíveis desnecessárias.