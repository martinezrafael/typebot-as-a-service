# Integração Typebot → Chatwoot

## Objetivo

Transferir atendimentos iniciados pelo Typebot para atendentes humanos no Chatwoot.

## Fluxo de atendimento

1. O Typebot recebe a mensagem do cliente.
2. O bot coleta nome, telefone e motivo do contato.
3. O cliente solicita atendimento humano.
4. Um serviço intermediário recebe a solicitação.
5. O serviço localiza ou cria o contato no Chatwoot.
6. Uma conversa é criada ou localizada.
7. O contexto do atendimento é encaminhado.
8. A conversa é direcionada à equipe responsável.
9. O bot deixa de responder enquanto o atendimento humano estiver ativo.

## Segurança

- Não armazenar tokens administrativos diretamente no Typebot.
- Manter credenciais em variáveis de ambiente.
- Validar as requisições recebidas pelo serviço intermediário.
- Não registrar senhas ou tokens nos logs.
- Evitar contatos e conversas duplicados.

## Componentes necessários

- Typebot Builder e Viewer.
- Chatwoot.
- API do Chatwoot.
- Serviço intermediário de integração.
- Banco de dados para controle das transferências.

## Pendências de desenvolvimento

- Implementar o serviço intermediário.
- Criar autenticação entre Typebot e integração.
- Implementar busca e criação de contatos.
- Implementar criação de conversas.
- Encaminhar histórico e contexto.
- Implementar atribuição de equipes.
- Controlar quando o bot deve parar ou retomar o atendimento.

## Integração futura com WhatsApp

A WhatsApp Cloud API deverá utilizar um componente responsável por
controlar o recebimento e o envio de mensagens.

Esse componente deverá impedir respostas simultâneas do Typebot e Chatwoot
e respeitar as políticas e os limites definidos pela Meta.
