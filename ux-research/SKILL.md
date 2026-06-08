---
name: ux-research
description: UX Research skill para "O meu Salmo" — gera usuários sintéticos baseados nas personas do projeto, conduz testes de usabilidade simulados, identifica pontos de fricção em fluxos críticos e produz relatório de achados acionáveis para o designer e tech leads.
user-invocable: true
---

# UX Research — O meu Salmo

Skill especializada em pesquisa de experiência do usuário para o app "O meu Salmo". Opera com cinco personas sintéticas calibradas para o público brasileiro de cristãos em vulnerabilidade emocional. Usa os arquivos de personas e protocolo nesta pasta como fonte da verdade.

## Arquivos desta skill

```
ux-research/
├── SKILL.md                          ← este arquivo (skill)
├── personas-sinteticas.md            ← 5 usuários sintéticos com perfil completo
└── protocolo-teste-usabilidade.md    ← roteiro de tarefas, critérios e métricas
```

## O que esta skill faz

### 1. Teste de usabilidade simulado
Dado um fluxo ou tela do app, executa o teste com cada persona sintética:
- Simula o ponto de vista, vocabulário e limitações técnicas de cada perfil
- Prevê onde o usuário vai hesitar, errar ou abandonar
- Identifica gaps entre o modelo mental do usuário e o design atual
- Classifica achados por **severidade**: crítico / moderado / cosmético

### 2. Análise de fluxo por persona
Para qualquer um dos 5 fluxos críticos do app:
1. **Hábito diário** — notificação → Início → Leitura → Áudio
2. **Emocional** — Coleções → escolhe emoção → Leitura
3. **Compartilhamento** — Leitura → Compartilhar → Compositor → share nativo
4. **Descoberta** — Salmos → busca por número/palavra → Leitura
5. **Fidelização** — Favoritar → acessa Favoritos → Leitura

### 3. Relatório de achados
Produz achado no formato:
```
[PERSONA] → [TAREFA] → [PONTO DE FRICÇÃO]
Severidade: crítico / moderado / cosmético
Hipótese de causa: ...
Recomendação: ...
```

### 4. Priorização
Agrega achados de todas as personas, ordena por:
- Frequência de impacto (quantas personas afetadas)
- Severidade
- Alinhamento com métricas críticas do MVP (retenção D1/D7/D30, compartilhamentos)

## Como usar

### Teste rápido de uma tela
```
/ux-research

Testa a tela de Leitura do Salmo com todas as personas.
Foca no fluxo de compartilhamento (botão compartilhar → compositor → share).
```

### Teste focado em persona específica
```
/ux-research

Simula a Ana Lúcia tentando encontrar a coleção de Ansiedade pela primeira vez.
Ela nunca usou o app antes. Descreve o que ela faz tela a tela.
```

### Análise de onboarding / primeira abertura
```
/ux-research

Todas as personas abrem o app pela primeira vez.
Identifica pontos de abandono potencial no D0.
```

### Relatório completo pré-lançamento
```
/ux-research

Relatório completo de usabilidade do MVP.
Testa os 5 fluxos críticos com as 5 personas.
Prioriza os 10 achados mais críticos para resolver antes do lançamento.
```

## Regras desta skill

- Nunca inventar comportamento de usuário desconexo do perfil documentado em `personas-sinteticas.md`
- Achados devem sempre mapear para um fluxo concreto do app (ver `arquitetura-informacao.md`)
- Recomendações devem respeitar tokens e princípios do Design System (`design-system.html`)
- Severidade **crítico** = abandono de fluxo ou não-conclusão de tarefa essencial
- Severidade **moderado** = fricção que aumenta tempo de tarefa ou cria frustração
- Severidade **cosmético** = inconsistência visual ou confusão menor que não impede conclusão

## Contexto do app (resumo)

**O meu Salmo** é um app Android de Salmos com curadoria por emoção (8 coleções: Ansiedade, Sono, Gratidão, Luto, Esperança, Perdão, Louvor, Proteção). Público: cristãos brasileiros em momentos de vulnerabilidade. MVP gratuito, sem anúncios. Motor de crescimento: compartilhamento de versículo como imagem no WhatsApp/Instagram.

Métricas críticas: retenção D1/D7/D30, compartilhamentos de imagem, abertura via notificação diária.
