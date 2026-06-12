# Roadmap — App de Salmos

Visão única de todo o projeto, para não se perder entre as frentes.
Documento complementar ao "Brief" e ao "Escopo Técnico".

---

## Como o projeto se organiza (o mapa mental)

O projeto tem **três frentes** correndo em paralelo, e cada uma tem o seu "lugar":

| Frente | Onde acontece | O que entrega |
|---|---|---|
| **1. Estratégia, marca e visual** | Aqui, no chat do Projeto | Posicionamento, nome, identidade visual, landing page |
| **2. Conteúdo** | Chats de conteúdo + GitHub | 150 salmos (domínio público), áudios TTS, micro-reflexões |
| **3. Desenvolvimento do app** | Claude Code (repositório) | O app Flutter, feature por feature |

O **GitHub** costura as frentes 2 e 3: o conteúdo nasce na frente 2, é salvo no repositório e o app (frente 3) consome de lá.

**Regra de ouro para não travar:** as três frentes avançam em paralelo. O desenvolvimento **não precisa esperar** o conteúdo real — ele roda com dados de exemplo até os 150 salmos ficarem prontos. Tudo só precisa convergir na fase de lançamento.

---

## Fase 0 — Fundação ✅ (concluída)

- [x] Pesquisa de mercado e validação do nicho
- [x] Posicionamento (experiência emocional, ecumênico via Salmos)
- [x] Decisões de monetização (MVP grátis + "Apoie"; resto depois)
- [x] Brief do projeto + Escopo técnico do MVP
- [x] Stack definida (Flutter, offline-first, Android-first)

## Fase 1 — Construção do MVP 🔨 (você está aqui)

As três frentes rodam juntas:

**Frente Desenvolvimento (Claude Code) — uma feature por sessão**
- [x] Esqueleto do projeto + navegação
- [ ] Tela de leitura do Salmo (← próximo passo atual)
- [ ] Lista de Todos os Salmos + busca
- [ ] Coleções (lista + detalhe)
- [ ] Salmo do dia (Home) + notificação local
- [ ] Favoritar
- [ ] Player de áudio
- [ ] Compositor de imagem + compartilhamento (motor de crescimento)
- [ ] Firebase Analytics
- [ ] Botão Apoie + camada de Entitlements
- [ ] Polimento visual e ícone

**Frente Conteúdo**
- [ ] Confirmar tradução de domínio público
- [ ] Estruturar os 150 salmos no JSON + definir coleções temáticas
- [ ] Gerar áudios TTS (começar pelos das coleções)
- [ ] Escrever micro-reflexões (só as das coleções no MVP)
- [ ] Salvar tudo no GitHub

**Frente Marca / Visual (aqui no chat)**
- [ ] Benchmarking de estilo visual
- [ ] Identidade visual (briefing de marca)
- [ ] Nome do app
- [ ] Logo e ícone
- [ ] Landing page

## Fase 2 — Pré-lançamento 🚦

- [x] Conta no Google Play Console (US$ 25) — criada em 2026-06-12
- [x] Política de privacidade publicada (omeusalmo.github.io/o-meu-salmo/privacy_policy.html)
- [ ] Teste fechado: 12 testadores por 14 dias (exigência atual)
- [ ] ASO: ícone, screenshots, descrição (palavras: salmos, ansiedade, oração, dormir)
- [ ] Analytics validado (eventos disparando de verdade)
- [x] Landing page no ar (V2 — github.io; domínio próprio pendente)

## Fase 3 — Lançamento 🚀

- [ ] Publicar no Google Play
- [ ] Divulgação inicial (compartilhamento orgânico, redes, comunidade/igreja)

## Fase 4 — Aprender e iterar 📊

- [ ] Acompanhar métricas: retenção, engajamento, compartilhamentos
- [ ] Ouvir os primeiros usuários
- [ ] v1.1: widget na tela inicial, mais coleções e reflexões, busca avançada
- [ ] v1.1: conta opcional com Google para backup/sync de favoritos — local-first continua sem conta; convite contextual após o 3º favorito; exige fluxo de exclusão de conta (Play) e atualização do Data Safety/LGPD. Decidido em 2026-06-12: nunca como gate obrigatório.

## Fase 5 — Crescer e monetizar 💰 (só com sinal de retenção)

- [ ] Premium (áudio premium, offline total) ligado via Entitlements
- [ ] Afiliados/recomendações na landing page (não no app)
- [ ] Expandir para iOS
- [ ] Avaliar evolução do "Apoie" para assinatura

---

## Como tocar isso na prática (orquestração)

- **Uma sessão do Claude Code = uma feature.** Siga a ordem da Frente Desenvolvimento. Sempre teste antes de seguir.
- **Use o `CLAUDE.md` + pasta `docs/`** no repositório pra o Claude Code lembrar do contexto a cada sessão.
- **Estratégia e marca ficam aqui no Projeto**, onde o brief dá o contexto.
- **Não espere uma frente pra avançar outra.** Travou numa, vá pra outra.
- **Ponto de convergência = Fase 2.** É quando conteúdo real, app e marca se juntam pra publicar.

---

## Atalho mental: o que fazer "amanhã"?

Se bater dúvida sobre qual o próximo passo, escolha pela frente que estiver mais "fria":
1. App parado? → próxima feature no Claude Code.
2. Conteúdo parado? → avançar salmos/áudios no GitHub.
3. Marca parada? → próximo prompt de marca aqui no Projeto.
