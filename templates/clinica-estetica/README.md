# Template — Clínica de Estética

## 1. Objetivo

Desenvolver um fluxo automatizado de atendimento para uma clínica de estética, utilizando o Typebot como ferramenta de automação conversacional, WhatsApp como canal de comunicação e Chatwoot para gerenciamento do atendimento humano.

O objetivo é automatizar o primeiro contato com potenciais clientes, apresentar os serviços oferecidos pela clínica, esclarecer dúvidas comerciais e facilitar solicitações de agendamento.

## 2. Funcionalidades

### 2.1. Recepção automática
- Receber novos contatos.
- Apresentar a clínica.
- Identificar o cliente.
- Disponibilizar o menu principal.

### 2.2. Apresentação de procedimentos
- Listar os procedimentos disponíveis.
- Apresentar descrições comerciais.
- Informar valores, quando cadastrados e aprovados.
- Direcionar interessados para solicitação de agendamento.

### 2.3. Agendamento
- Identificar o procedimento de interesse.
- Coletar dados básicos do cliente.
- Registrar a preferência de data e horário.
- Encaminhar a solicitação para confirmação da equipe.

### 2.4. Informações institucionais
- Consultar endereço.
- Consultar horários de funcionamento.
- Consultar telefone e canais de contato.
- Consultar formas de pagamento.

### 2.5. Atendimento humano
- Transferir conversas para o Chatwoot.
- Encaminhar o contexto do atendimento.
- Permitir continuidade da conversa por um atendente.

## 3. Tecnologias

| Tecnologia | Responsabilidade |
|---|---|
| Typebot | Construção e execução dos fluxos automatizados. |
| WhatsApp Cloud API | Comunicação pelo WhatsApp. |
| Chatwoot | Gerenciamento das conversas e atendimento humano. |

## 4. Fluxo de atendimento

1. Cliente inicia uma conversa pelo WhatsApp.
2. Bot apresenta as boas-vindas.
3. Cliente acessa o menu principal.
4. Bot identifica a necessidade do cliente.
5. Cliente navega pelas opções disponíveis.
6. Bot apresenta informações ou coleta dados.
7. Quando necessário, a conversa é transferida para um atendente.
8. Atendimento é finalizado.

## 5. Regras gerais

- Utilizar linguagem cordial, profissional e humanizada.
- Não apresentar informações comerciais que não tenham sido aprovadas pela clínica.
- Não inventar preços, horários ou disponibilidade.
- Não realizar diagnósticos ou recomendações clínicas.
- Questões relacionadas à saúde devem ser encaminhadas a profissionais habilitados.
- Disponibilizar atendimento humano durante a navegação.
- Solicitações de agendamento devem ser consideradas pendentes até a confirmação da disponibilidade.

## 6. Personalização

As informações abaixo deverão ser preenchidas durante a implantação:

- Nome da clínica.
- Logotipo e identidade visual.
- Endereço.
- Horários de funcionamento.
- Lista de procedimentos.
- Valores e condições comerciais.
- Formas de pagamento.
- Número de WhatsApp.
- Informações sobre agendamento.
- Equipe responsável pelo atendimento.