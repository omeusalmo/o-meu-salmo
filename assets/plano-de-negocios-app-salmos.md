# Plano de Negócios — App de Salmos

Documento estratégico do projeto. Versão 1 · MVP Android-first.
Complementar ao Brief, Escopo Técnico e Roadmap.

---

## 1. Resumo executivo

Um app de Salmos com visual moderno, áudio narrado e curadoria por emoção (ansiedade, sono, gratidão, luto). Não compete com apps de "ler a Bíblia de graça" — entrega uma **experiência** de conforto e constância. Foco inicial: Brasil, só Google Play, gratuito, com objetivo de validar engajamento antes de monetizar. Projeto solo, de baixo custo (lançamento por menos de US$ 300 + tempo), desenvolvido com Claude Code.

## 2. Problema e oportunidade

O público religioso brasileiro é enorme e engajado, mas os apps disponíveis se dividem entre gigantes gratuitos com design datado (foco em "ler a Bíblia") e apps premium estrangeiros, em inglês e caros. Falta uma opção **em português, com design moderno, áudio e curadoria emocional**, com preço de bolso brasileiro. Salmos é o livro mais lido da Bíblia nos apps — demanda comprovada.

## 3. Solução (o produto)

Um app focado em Salmos que combina:
- Leitura com tipografia caprichada e visual sereno.
- Áudio narrado dos salmos.
- Coleções temáticas por emoção/situação.
- Salmo do dia + notificação para criar hábito.
- Compartilhamento de versículo como imagem (motor de crescimento).
- Micro-reflexões devocionais originais (conteúdo próprio, não frases genéricas).

## 4. Proposta de valor e diferenciação

- **Experiência, não conteúdo:** o texto bíblico é commodity; o produto é o design, o áudio e a curadoria.
- **Nicho emocional:** "Salmos para a ansiedade / para dormir / para gratidão".
- **Ecumênico:** Salmos funcionam para católicos e evangélicos.
- **Conteúdo próprio:** micro-reflexões escritas pelo dono reforçam a identidade.

## 5. Mercado (Brasil)

- País fortemente religioso (Censo 2022 do IBGE): ~56,7% católicos (100,2 mi) e ~26,9% evangélicos (47,4 mi), com evangélicos em crescimento acelerado.
- Mercado de "bem-estar espiritual" global estimado em ~US$ 2,16 bi em 2024, projetado para ~US$ 7,31 bi até 2033 (crescimento ~14,6% ao ano).
- Referência de engajamento: a YouVersion já passou de 85 mi de downloads no Brasil, com ~1,1 mi de pessoas usando diariamente.
- **Android domina (~88%)**; iOS é minoria (~12%), mas concentra quem paga.

## 6. Concorrência

- **Gigantes gratuitos:** YouVersion (Bíblia geral, grátis, doações), Bíblia Sagrada Mobidic (forte no BR).
- **Premium modernos (referência de produto):** Hallow (22 mi+ downloads, US$ 157 mi captados), Glorify (US$ 86 mi captados), Pray.com (18 mi+ downloads) — todos com modelo de assinatura freemium.
- **Apps BR especializados:** católicos (Liturgia Diária, Católico Orante) e evangélicos (rádios e devocionais com anúncios), em geral com design datado.
- **Posição:** não brigar por "ler a Bíblia"; ocupar a brecha de experiência + nicho emocional em português.

## 7. Público-alvo

Pessoas religiosas (católicas e evangélicas) que buscam conforto, calma e constância espiritual no dia a dia — especialmente em momentos de ansiedade, insônia ou luto. Maioria em Android. Sensíveis a uma experiência bonita e a conteúdo que sentem ser "do bem".

## 8. Modelo de negócio e monetização (faseado)

- **MVP:** gratuito, sem anúncios. Único elemento de receita: botão **"Apoie o app"** discreto (compra única via Google Play Billing). Objetivo é engajamento, não receita.
- **Arquitetura preparada:** camada de "Entitlements" permite ligar premium no futuro sem retrabalho.
- **Pós-validação:** premium (áudio premium, offline total, sem anúncios) com preço de bolso brasileiro (bem abaixo dos US$ 7–9/mês do Hallow); avaliar mensal barato + anual com desconto, ou opção vitalícia.
- **Web (futuro):** seção de recomendações com links de afiliado na **landing page** (não no app — a Amazon restringe afiliados dentro de apps).
- **Princípio:** anúncios, se um dia entrarem, só na camada gratuita e nunca no meio da experiência de oração.

## 9. Estratégia de crescimento

- **Motor principal:** compartilhamento de versículo como imagem (status de WhatsApp e stories) — distribuição orgânica e gratuita, essencial num MVP sem verba.
- **ASO:** otimizar para "salmos", "ansiedade", "oração", "dormir".
- **Comunidade:** igrejas, grupos e a rede pessoal como primeiros usuários/testadores.
- **Retenção:** salmo do dia + notificação + coleções por emoção criam hábito.

## 10. Estrutura de custos (1º ano)

| Item | Custo | Tipo |
|---|---|---|
| Google Play Console | US$ 25 | Única vez |
| Áudio TTS (150 salmos) | ~US$ 60–90 | Única vez |
| Claude Code Pro (durante o build) | US$ 20/mês | Recorrente temporário |
| Hospedagem (offline-first) | ~US$ 0 | — |
| Domínio (landing page, opcional) | ~US$ 10–15/ano | Recorrente |
| Apple Developer (só ao expandir p/ iOS) | US$ 99/ano | Futuro |

**Total para lançar no Android: < US$ 300 + tempo.** O maior investimento é o tempo de construção e curadoria.

## 11. Métricas de sucesso (o que validar)

- **Retenção** (D1, D7, D30) — a métrica mais importante do teste.
- **Engajamento:** salmos abertos, áudios tocados, tempo no app.
- **Crescimento:** nº de compartilhamentos de imagem e instalações orgânicas.
- **Hábito:** abertura via notificação do salmo do dia.
- **Sinal de monetização:** uso do "Apoie" (mesmo pequeno, indica disposição).

## 12. Riscos e mitigações

- **Concorrência da YouVersion (grátis e gigante):** não competir em conteúdo; vencer em experiência e nicho.
- **ARPU baixo no Brasil:** jogo de volume + preço acessível; não depender de ticket alto.
- **Precisão e direitos do texto:** usar tradução de domínio público confirmada e conferir o texto antes de publicar.
- **Tempo limitado (projeto solo):** escopo enxuto, uma feature por sessão, frentes em paralelo sem travar.
- **Engajamento não validar:** por isso o MVP é barato e gratuito — falhar custa pouco e ensina rápido.

## 13. Roadmap resumido

Fase 0 fundação ✅ → Fase 1 construção do MVP (dev + conteúdo + marca em paralelo) → Fase 2 pré-lançamento → Fase 3 lançamento no Google Play → Fase 4 aprender e iterar → Fase 5 crescer e monetizar (com sinal de retenção). Detalhes no documento "Roadmap".
