# Protocolo de Teste de Usabilidade — O meu Salmo MVP

Roteiro de tarefas, critérios de sucesso e métricas para testes simulados com as personas sintéticas. Use junto com `personas-sinteticas.md`.

---

## Como usar este protocolo

1. Escolha uma ou mais personas de `personas-sinteticas.md`
2. Escolha um cenário abaixo (ou todos, para relatório completo)
3. Para cada tarefa, simule o ponto de vista da persona:
   - O que ela vê? O que ela tenta fazer?
   - Onde hesita? O que confunde?
   - Conclui a tarefa? Em quanto tempo estimado?
4. Classifique cada achado por severidade e registre recomendação

---

## Métricas de referência (MVP)

| Métrica | Definição | Meta |
|---|---|---|
| Taxa de conclusão de tarefa | % personas que completam sem ajuda | ≥ 80% por tarefa |
| Erros críticos | Ações erradas que bloqueiam o fluxo | 0 por persona |
| Tempo estimado de tarefa | Estimativa de toques/segundos para concluir | definido por tarefa |
| Satisfação declarada (simulada) | Reação emocional esperada ao concluir | Neutra a Positiva |

---

## Cenários e tarefas

---

### Cenário A — Primeira abertura do app (D0)

**Contexto:** Persona instala o app pela primeira vez. Nenhuma instrução prévia.

**Objetivo:** Identificar pontos de abandono no D0.

**Tarefas:**
1. Abra o app pela primeira vez
2. Entenda o que o app faz sem ler nenhuma documentação
3. Execute uma ação que pareça "o próximo passo natural"

**Critério de sucesso:**
- Persona navega para pelo menos uma tela além da tela inicial sem ajuda
- Persona consegue descrever o que o app faz ("é um app de Salmos")

**Personas prioritárias:** Ana Lúcia (baixa literacia), Giovanna (atenção curta)

**Perguntas de diagnóstico:**
- A tela de Início/Salmo do dia é auto-explicativa?
- A navegação inferior (4 abas) é intuitiva para cada perfil?
- O nome das abas (Início, Coleções, Salmos, Favoritos) é compreensível?
- O eyebrow label "O MEU" + "Salmo" em Playfair é reconhecível como logotipo?

---

### Cenário B — Fluxo emocional (proposta central do app)

**Contexto:** Persona está em momento de vulnerabilidade emocional e quer conforto.

**Objetivo:** Validar se o fluxo Coleções → emoção → Salmo é fluido e emocionalmente ressonante.

**Tarefa única:**
> Você está ansioso(a) e quer encontrar um Salmo que ajude. Use o app para isso.

**Subtarefas implícitas:**
1. Encontra a aba Coleções
2. Identifica "Ansiedade" como categoria relevante
3. Entra na Coleção de Ansiedade
4. Seleciona um Salmo da lista
5. Lê o Salmo na tela de Leitura

**Critério de sucesso:** Persona chega à tela de Leitura em ≤ 5 toques

**Personas prioritárias:** Tiago (vai direto), Fernanda (busca Luto), Giovanna (busca Sono)

**Perguntas de diagnóstico:**
- Os nomes das coleções ("Ansiedade", "Sono", "Luto") são compreensíveis e acolhedores?
- O card de coleção comunica claramente o que está dentro?
- A lista de Salmos dentro de uma coleção é compreensível (número + título)?
- A tela de Leitura corresponde à expectativa emocional de cada persona?

---

### Cenário C — Busca por Salmo específico

**Contexto:** Persona já sabe qual Salmo quer (por número).

**Tarefa única:**
> Encontre o Salmo 23 e leia o primeiro versículo.

**Subtarefas implícitas:**
1. Encontra a aba "Salmos" (todos os 150)
2. Localiza o Salmo 23 (lista ou busca)
3. Abre o Salmo
4. Lê o primeiro versículo

**Critério de sucesso:** Persona chega ao versículo em ≤ 4 toques, ≤ 30 segundos estimados

**Personas prioritárias:** Ana Lúcia (pensa por número), Pastor Renato (testa busca)

**Perguntas de diagnóstico:**
- A aba "Salmos" é encontrada intuitivamente na navegação inferior?
- A lista de 150 Salmos é escaneável (número + título visíveis)?
- A função de busca é descobrível (ícone? posição?)?
- Buscar "23" retorna o Salmo 23 imediatamente?

---

### Cenário D — Áudio (retenção e hábito)

**Contexto:** Persona quer ouvir o Salmo narrado.

**Tarefa única:**
> Toque o áudio do Salmo que está lendo. Pause e retome.

**Subtarefas implícitas:**
1. Encontra o player de áudio na tela de Leitura
2. Toca o play
3. Pausa
4. Retoma

**Critério de sucesso:** Persona executa play/pause sem hesitação, ≤ 2 toques

**Personas prioritárias:** Ana Lúcia (usa para dormir), Giovanna (ouve no escuro)

**Perguntas de diagnóstico:**
- O player de áudio é visível na tela de Leitura sem rolar (above the fold)?
- O ícone de play é reconhecível e grande o suficiente para toque seguro (≥ 48px)?
- O estado de play vs. pause é visualmente claro?
- O áudio continua em background quando a tela apaga? (Giovanna coloca o celular virado)

---

### Cenário E — Compartilhamento (motor de crescimento)

**Contexto:** Persona quer compartilhar um versículo como imagem.

**Tarefa única:**
> Compartilhe um versículo do Salmo 23 como imagem no WhatsApp.

**Subtarefas implícitas:**
1. Encontra o botão de compartilhar na tela de Leitura
2. Entra no Compositor de Imagem
3. Seleciona um versículo
4. Escolhe um fundo
5. Aciona o share nativo do sistema

**Critério de sucesso:** Persona chega ao share nativo do sistema em ≤ 7 toques

**Personas prioritárias:** Ana Lúcia (compartilha no status do WhatsApp), Tiago (Instagram Stories)

**Perguntas de diagnóstico:**
- O botão compartilhar é encontrado intuitivamente (ícone padrão de share do sistema)?
- A transição para o Compositor é clara (a persona entende que vai gerar uma imagem)?
- A seleção de versículo é intuitiva (toque no verso = seleciona?)?
- A seleção de fundo é compreensível (quantas opções? com preview?)?
- A imagem gerada é visualmente adequada para o status do WhatsApp (proporção, fonte, cores)?
- O share nativo abre com WhatsApp como primeira opção na maioria dos dispositivos?

---

### Cenário F — Favoritar e encontrar depois

**Contexto:** Persona quer salvar um Salmo para reler.

**Tarefa única:**
> Salve o Salmo 91 como favorito. Depois, encontre-o na aba Favoritos.

**Subtarefas implícitas:**
1. Abre o Salmo 91
2. Localiza e toca o botão de favoritar
3. Navega para a aba Favoritos
4. Encontra o Salmo 91 na lista

**Critério de sucesso:** Persona completa o ciclo em ≤ 5 toques, confirma que o salmo está salvo

**Personas prioritárias:** Fernanda (alta retenção, relê), Ana Lúcia (quer rever os favoritos)

**Perguntas de diagnóstico:**
- O ícone de favoritar é reconhecível (coração? estrela?) e está em posição acessível?
- O feedback visual de "favoritado" (estado ativo do ícone) é claro?
- A aba Favoritos comunica estado vazio adequadamente se não há nada salvo?
- A lista de favoritos é ordenada de forma que faça sentido (última abertura? ordem de salmo?)?

---

### Cenário G — Ajustes e notificação diária (hábito)

**Contexto:** Persona quer configurar o horário da notificação diária.

**Tarefa única:**
> Configure o app para te notificar com o Salmo do dia às 7h da manhã.

**Subtarefas implícitas:**
1. Encontra o acesso a Ajustes (ícone de engrenagem na barra superior)
2. Localiza a opção de notificação
3. Altera o horário para 7h00
4. Confirma a mudança

**Critério de sucesso:** Persona altera o horário sem confusão, ≤ 3 toques após encontrar Ajustes

**Personas prioritárias:** Ana Lúcia (rotina matinal), Tiago (quer criar hábito)

**Perguntas de diagnóstico:**
- O ícone de engrenagem na barra superior é suficientemente visível?
- A persona percebe que Ajustes NÃO está na navegação inferior?
- O controle de horário (time picker) é padrão do sistema ou customizado?
- A mudança de horário tem confirmação visual clara?

---

## Template de relatório de achado

```
---
ACHADO #[número]

Persona: [Nome]
Cenário: [Letra + Nome do cenário]
Tarefa: [Número da subtarefa]

O que aconteceu:
[Descreva o comportamento esperado da persona — o que ela tentou, onde errou]

Ponto de fricção:
[Nome/localização exata do elemento de UI que causou o problema]

Severidade: [CRÍTICO / MODERADO / COSMÉTICO]
- CRÍTICO = não completou a tarefa
- MODERADO = completou mas com hesitação, erro recuperável, ou frustração
- COSMÉTICO = completou, mas algo causou estranheza visual ou vocabular

Hipótese de causa:
[Por que o design atual não correspondeu ao modelo mental desta persona?]

Impacto em métricas MVP:
[Retenção / Compartilhamento / Hábito / Outra]

Recomendação:
[Mudança específica de design, copy ou fluxo. Deve respeitar os tokens do DS.]
---
```

---

## Checklist pré-lançamento de usabilidade

Execute todos os cenários com todas as personas antes do lançamento na Google Play. Marque como ✅ quando não houver achados críticos ou moderados.

| Cenário | Ana Lúcia | Tiago | Fernanda | Pastor Renato | Giovanna |
|---------|-----------|-------|----------|----------------|----------|
| A — Primeira abertura | ☐ | ☐ | ☐ | ☐ | ☐ |
| B — Fluxo emocional | ☐ | ☐ | ☐ | ☐ | ☐ |
| C — Busca por número | ☐ | ☐ | ☐ | ☐ | ☐ |
| D — Áudio | ☐ | ☐ | ☐ | ☐ | ☐ |
| E — Compartilhamento | ☐ | ☐ | ☐ | ☐ | ☐ |
| F — Favoritar | ☐ | ☐ | ☐ | ☐ | ☐ |
| G — Notificação | ☐ | ☐ | ☐ | ☐ | ☐ |

**Critério de lançamento:** 0 achados CRÍTICOS. Achados MODERADOS documentados com roadmap de resolução.
