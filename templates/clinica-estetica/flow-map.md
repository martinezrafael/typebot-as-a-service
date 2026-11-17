# Mapa do Fluxo

## 1. Fluxo principal

```text
                         INÍCIO
                            |
                            v
                      BOAS-VINDAS
                            |
                            v
                   IDENTIFICAÇÃO CLIENTE
                            |
                            v
                     MENU PRINCIPAL
                            |
       +--------------------+---------------------+
       |                    |                     |
       v                    v                     v
 CONHECER             SOLICITAR              CONSULTAR
 PROCEDIMENTOS        AGENDAMENTO             INFORMAÇÕES
       |                    |                     |
       v                    v                     |
 LISTA DE              ESCOLHER                   |
 PROCEDIMENTOS         PROCEDIMENTO                |
       |                    |                     |
       v                    v                     v
 DETALHES DO           COLETAR DADOS          ENDEREÇO /
 PROCEDIMENTO          DO CLIENTE             HORÁRIOS
       |                    |                     |
       v                    v                     |
 DEMONSTRAR            ESCOLHER                   |
 INTERESSE             DATA/PERÍODO                |
       |                    |                     |
       |                    v                     |
       |              RESUMO DA SOLICITAÇÃO       |
       |                    |                     |
       |                    v                     |
       |              REGISTRAR SOLICITAÇÃO       |
       |                    |                     |
       +--------------------+---------------------+
                            |
                            v
                      MENU PRINCIPAL

                            |
                            v
                    FALAR COM ATENDENTE
                            |
                            v
                       CHATWOOT
                            |
                            v
                    ATENDIMENTO HUMANO
```

## 2. Menu principal

O menu principal deverá apresentar as seguintes opções:

1. Conhecer procedimentos.
2. Solicitar agendamento.
3. Consultar endereço e horários.
4. Consultar formas de pagamento.
5. Falar com atendente.

## 3. Fluxos secundários

### 3.1. Conhecer procedimentos

```text
MENU PRINCIPAL
      |
      v
LISTA DE PROCEDIMENTOS
      |
      v
SELECIONAR PROCEDIMENTO
      |
      v
APRESENTAR DESCRIÇÃO
      |
      v
DESEJA CONTINUAR?
      |
      +--> Solicitar agendamento
      |
      +--> Conhecer outro procedimento
      |
      +--> Voltar ao menu
      |
      +--> Falar com atendente
```

### 3.2. Solicitar agendamento

```text
MENU PRINCIPAL
      |
      v
SELECIONAR PROCEDIMENTO
      |
      v
INFORMAR NOME
      |
      v
INFORMAR TELEFONE
      |
      v
INFORMAR DATA DESEJADA
      |
      v
INFORMAR PERÍODO
      |
      v
CONFIRMAR INFORMAÇÕES
      |
      v
REGISTRAR SOLICITAÇÃO
      |
      v
AGUARDANDO CONFIRMAÇÃO
      |
      v
FINALIZAR
```

### 3.3. Informações institucionais

```text
MENU PRINCIPAL
      |
      +--> Endereço
      |
      +--> Horários
      |
      +--> Formas de pagamento
      |
      +--> Voltar ao menu
```

### 3.4. Atendimento humano

```text
QUALQUER ETAPA
      |
      v
SOLICITAR ATENDENTE
      |
      v
REGISTRAR CONTEXTO
      |
      v
TRANSFERIR PARA CHATWOOT
      |
      v
ATENDIMENTO HUMANO
```

## 4. Regras de navegação

- O cliente poderá solicitar atendimento humano em qualquer etapa.
- Os fluxos secundários deverão permitir retorno ao menu principal.
- O chatbot deverá tratar entradas inválidas.
- O atendimento deverá ser encerrado somente quando solicitado ou após conclusão do fluxo.
- Questões clínicas deverão ser direcionadas à equipe profissional.
- O bot não deverá continuar enviando mensagens automáticas após uma transferência bem-sucedida para atendimento humano.

## 5. Estados do atendimento

| Estado | Descrição |
|---|---|
| bot_active | Atendimento automatizado em andamento. |
| waiting_human | Aguardando atendimento humano. |
| human_active | Atendimento humano em andamento. |
| scheduling_pending | Solicitação de agendamento pendente. |
| scheduled | Agendamento confirmado. |
| closed | Atendimento encerrado. |