# Data Safety Form — O meu Salmo (respostas prontas p/ Play Console)

> TL;DR: preencher exatamente como abaixo. Reflete o app APÓS remoção do AD_ID (v1.0.1+3).
> Console → Política → Segurança dos dados. Atualizado 2026-08-01.

## 0. Declaração do ID de publicidade (App content / Conteúdo do app)

⚠️ **Ao subir o código 3 o Console dá erro** ("o app usa AD_ID mas o manifesto não inclui a permissão"). Esperado — o AD_ID foi removido de propósito (v1.0.1+3).
→ Clicar **"Atualizar a declaração"** → responder que o app **NÃO usa ID de publicidade** → salvar. Erro some.
(Antes, o código 2 declarava "usa". Agora não usa mais = alinhado com privacidade.)

## 1. Coleta e compartilhamento (visão geral)

- **O app coleta ou compartilha algum dos tipos de dados exigidos?** → **SIM** (via Firebase Analytics + Crashlytics do Google).
- **Todos os dados são criptografados em trânsito?** → **SIM** (HTTPS).
- **Você oferece forma de solicitar exclusão de dados?** → o app **não tem conta/login**; não há perfil pessoal. Marcar que os dados coletados são pseudônimos e o usuário controla via conta Google + desinstalar remove o local. (Se o form exigir URL de exclusão, apontar a política: `https://omeusalmo.com.br/privacy_policy.html`.)

## 2. Tipos de dados — declarar como COLETADO (nenhum como "compartilhado")

Para cada um abaixo: **Coletado = Sim**, **Compartilhado = Não**, **Processado de forma efêmera = Não**, **Coleta obrigatória = Não (opcional, opt-out no app)**, **Finalidade = Análise / Funcionalidade do app**. Nenhum para publicidade/marketing.

| Categoria | Tipo específico | Coletado? | Por quê |
|---|---|---|---|
| **Atividade no app** | Interações no app | ✅ Sim | Analytics (salmo aberto/favoritado/compartilhado, áudio, busca, coleção) |
| **App info e desempenho** | Registros de falhas (crash logs) | ✅ Sim | Crashlytics — estabilidade |
| **App info e desempenho** | Diagnóstico | ✅ Sim | Crashlytics — desempenho |
| **IDs do dispositivo ou outros** | ID do dispositivo ou outros | ✅ Sim | ID de instância do Firebase (pseudônimo). **NÃO** coleta advertising ID (removido). |

## 3. Tipos de dados — declarar como NÃO coletado

Nome, e-mail, telefone, endereço, qualquer info pessoal · Localização (precisa ou aproximada) · Info financeira · Saúde e fitness · Mensagens · Fotos/vídeos/arquivos · Contatos · Histórico de navegação/apps · **Advertising ID** · Áudio gravado.

Observações que valem marcar/saber:
- **Busca:** o app envia só `query_length` (tamanho) + `has_results`, **nunca o texto** buscado.
- **Emoção do onboarding** (Ansiedade/Luto…): fica **só no dispositivo**, nunca vai pro analytics.
- **Coleção aberta:** envia só `collection_id` agregado, **não** o título.

## 4. Classificação de conteúdo (questionário separado)
- Conteúdo religioso devocional. Sem violência/sexo/linguagem/drogas/apostas. → tende a **Livre / classificação mais baixa**.
- **NÃO** declarar temas sensíveis de saúde. O app é devocional, não médico.
