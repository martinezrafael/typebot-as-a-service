# Variáveis

## 1. Informações da clínica

| Variável | Descrição |
|---|---|
| NOME_CLINICA | Nome da clínica. |
| ENDERECO | Endereço completo. |
| HORARIO | Horários de funcionamento. |
| TELEFONE | Telefone comercial. |
| LINK_MAPS | Link de localização. |
| FORMAS_PAGAMENTO | Formas de pagamento aceitas. |

## 2. Identificação do cliente

| Variável | Descrição |
|---|---|
| NOME_CLIENTE | Nome utilizado durante a conversa. |
| NOME_COMPLETO | Nome completo do cliente. |
| TELEFONE_CLIENTE | Telefone para contato. |

## 3. Procedimentos

| Variável | Descrição |
|---|---|
| PROCEDIMENTOS | Lista de procedimentos disponíveis. |
| PROCEDIMENTO_INTERESSE | Procedimento selecionado pelo cliente. |
| NOME_PROCEDIMENTO | Nome do procedimento selecionado. |
| DESCRICAO_PROCEDIMENTO | Descrição comercial aprovada. |

## 4. Agendamento

| Variável | Descrição |
|---|---|
| DATA_PREFERIDA | Data desejada pelo cliente. |
| PERIODO_PREFERIDO | Período desejado. |
| STATUS_AGENDAMENTO | Estado da solicitação. |
| PROTOCOLO_AGENDAMENTO | Identificador da solicitação, se disponível. |

Valores de `STATUS_AGENDAMENTO`:

- pending
- confirmed
- cancelled

## 5. Atendimento

| Variável | Descrição |
|---|---|
| MOTIVO_ATENDIMENTO | Motivo principal do contato. |
| STATUS_ATENDIMENTO | Estado atual do atendimento. |
| MOTIVO_TRANSFERENCIA | Motivo do encaminhamento humano. |
| CHATWOOT_CONVERSATION_ID | Identificador da conversa no Chatwoot. |

Valores de `STATUS_ATENDIMENTO`:

- bot_active
- waiting_human
- human_active
- closed

## 6. Navegação

| Variável | Descrição |
|---|---|
| OPCAO_MENU | Opção selecionada no menu principal. |
| MENU_ORIGEM | Menu de origem da navegação. |
| ULTIMA_OPCAO | Última opção selecionada pelo cliente. |

## 7. Observações

- As variáveis deverão ser criadas no Typebot conforme a necessidade de cada fluxo.
- Utilizar nomes padronizados em letras maiúsculas.
- Evitar duplicidade de variáveis.
- Não armazenar tokens de integração.
- Não coletar informações clínicas sensíveis no fluxo comercial.
- Solicitações de agendamento devem permanecer pendentes até confirmação efetiva.