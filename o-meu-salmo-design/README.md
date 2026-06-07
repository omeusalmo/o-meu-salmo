# O meu Salmo — Design System

> Sistema de design da marca **O meu Salmo**: um app de Salmos com curadoria por **emoção**. Português do Brasil. Tom íntimo, contemplativo, sem peso religioso institucional.

Este sistema codifica a identidade visual já aprovada (cor, tipografia, logotipo, ícone, voz e componentes) para que **Claude Code** — ou qualquer dev/designer — construa o aplicativo e materiais mantendo total coerência.

---

## 1. Contexto do produto

**O que é:** um aplicativo (Android-first, depois iOS) que entrega Salmos selecionados a partir de **como a pessoa está se sentindo** — ansiedade, paz, gratidão, luto, dúvida. Cada Salmo pode ser **lido** e **ouvido** (áudio narrado).

**Para quem:** pessoas que buscam um momento de pausa, conforto e fé — frequentemente à noite, em momentos de vulnerabilidade (insônia, ansiedade, luto). Daí o **modo noturno ser o padrão emocional** da marca.

**Promessa / essência:** *"Uma pausa que devolve a você mesmo."* / *"Encontre as palavras certas para o que você sente."*

**O que a marca NÃO é:** não é "app gospel" (sem gradientes roxo-dourado, sem brilho, sem cruzes/pombas/halos). É sóbria, editorial, literária — o Saltério como um livro íntimo, não como um templo.

---

## 2. Índice de arquivos

| Arquivo | Conteúdo |
|---|---|
| `README.md` | Este guia — contexto, fundamentos de conteúdo e visuais, iconografia |
| `SKILL.md` | Manifesto da skill (compatível com Agent Skills / Claude Code) |
| `design-system.html` | **Referência visual completa** — todas as cores, tipo, espaçamento, componentes e acessibilidade numa única página. Toggle dark/light integrado. |
| `colors_and_type.css` | **Tokens** CSS: cores (cobalto, âmbar, emoções, dark/light), tipografia, espaçamento, sombras, raios. **Importe este arquivo.** |
| `assets/` | Ícone do app: `app-icon-512.png` (raster master) e `app-icon.svg` (vetorial) |
| `brand/` | Entregáveis de marca: identidade visual, acessibilidade, ícone, card de compartilhamento |
| `docs/` | Documentação: arquitetura de informação e guia de voz & tom |
| `preview/*.html` | Cartões do Design System (cor, tipo, componentes, marca) |
| `ui_kits/app/` | UI kit: telas (home, leitura, emoções) + componentes JSX |

---

## 3. Fundamentos de conteúdo (voz & tom)

> Guia completo em [`docs/ux-writing-voice-and-tone.md`](docs/ux-writing-voice-and-tone.md). O resumo abaixo cobre os princípios inegociáveis para uso rápido.

**Pronome:** sempre **"você"**. App fala em 1ª pessoa em contextos de chegada ("eu encontro as palavras").

**Tom:** sereno · íntimo · poético · humilde · contemplativo. Frases curtas. Silêncio é parte da mensagem.

**Casing:** Sentence case em quase tudo. VERSALETE só em eyebrow labels e no "O MEU" do logotipo.

**Sem emoji.** Quebra a sobriedade.

**Termos canônicos:** `Salmo` (maiúsculo), `coleção`, `sentimento`, `favoritos`, `apoiar` (CTAs), `tradução`.

**Exemplos de voz:**

| Contexto | Texto |
|---|---|
| Chegada (home) | "Para hoje," |
| Coleções | "Como você está chegando hoje?" |
| Descrição | "Escolha um sentimento — eu encontro as palavras." |
| Offline | "Você está offline — seus Salmos continuam aqui." |
| Busca vazia | "Não encontrei nada assim. Tente uma emoção?" |
| Notificação | "Há um Salmo esperando por você." |
| Favorito salvo | "Guardado nos favoritos." |

**Referência bíblica:** `Salmo 46 · 10` (ponto-médio). Em labels curtos: `46 · 10`.

---

## 4. Fundamentos visuais

### Cor
- **Principal — Cobalto `#2A47DD`** (Luminous Blue, tendência WGSN 2027 associada a "espiritualidade e emoção"). Único acento de interface: botões, ícones ativos, "Salmo" do logo, progresso.
- **Secundária — Âmbar**, usada **com extrema parcimônia**: marca apenas o **versículo em destaque** e peças sociais. Nunca é cor de UI. `#C4A86A` sobre escuro (AAA); `#8A6A28` para texto sobre claro (AA).
- **Dois modos.** Noturno é o padrão (fundo `#080B1C`, cobalto-noite quase-preto). Diurno é off-white frio-mineral (`#F5F7FE`) — nunca branco puro, nunca preto puro.
- **Emoções:** cada emoção tem uma cor própria (chip + tinta + ponto), estável entre os modos. É um *sistema de navegação*, não decoração.

### Tipografia
- **Playfair Display** (serif display, italic 500) — números do salmo, títulos, a palavra "Salmo". Elegante, editorial.
- **Cormorant** (serif, italic 400) — o **corpo do salmo** (versículos). Literário, respirado, lh 1.65.
- **Instrument Sans** (sans, 300–500) — UI, labels, o versalete "O MEU".
- Escala generosa, muito respiro. Em mobile, corpo do salmo ≥ 18px.
- **Proibidas:** Inter, Roboto, Arial, Comic Sans, góticas, caligrafia de banner de culto.

### Forma, espaço e movimento
- **Raios:** cards/superfícies 14–22px; ícone do app squircle ~22.7%; pílulas para chips de emoção.
- **Sombras:** frias e suaves (base `rgba(8,11,28,…)`), nunca pretas duras. Realce do ícone/botão usa sombra cobalto `rgba(27,51,180,.30)`.
- **Espaçamento:** base 4px. Generoso. Uma coluna no mobile, foco, muito branco/escuro.
- **Movimento:** calmo, sem bounce. Fades + subida sutil (`translateY`). Easing `cubic-bezier(.22,.61,.36,1)`. Durações 0.18–0.7s. **Conteúdo essencial nunca depende de animação para aparecer.**
- **Hover/press:** clarear/escurecer o cobalto um passo na escala (400↔600); press pode reduzir opacidade levemente. Nada de escala agressiva.

### O que evitar (anti-padrões da marca)
Gradiente roxo/azul-royal com dourado brilhante · branco/preto puros · fontes proibidas · cruzes/pombas/halos/raios celestiais · ícones preenchidos pesados · layouts densos e multi-coluna no mobile.

---

## 5. Logotipo & ícone

**Sem símbolo isolado.** A marca se expressa por **dois ativos apenas**:

1. **Logotipo** (site, LP, materiais): "**O MEU**" em versalete Instrument Sans (tracking .34em), **alinhado à esquerda**, sobre "**Salmo**" em Playfair Display itálico 500. "Salmo" recebe o cobalto. Reproduzível 100% em CSS — ver `.ds-logotype` em `colors_and_type.css`.
2. **Ícone** (app + avatares de redes sociais): o tile inteiro é a **capa de um livro** em cobalto cheio; uma **fita branca** (marcador) desce da borda superior à direita; o nome "O meu Salmo" centralizado em branco. Ver `assets/app-icon-512.png`.

**Regra de aplicação:** logotipo onde há espaço horizontal (web). Ícone onde o espaço é quadrado e pequeno (app store, perfis). Respeitar área segura de 66% (Android adaptativo) — o logotipo dentro do ícone nunca encosta nas bordas.

---

## 6. Iconografia

- **Estilo:** sempre **outline**, traço fino e arredondado (`stroke-linecap/linejoin: round`), ~1.5–2px no grid 24. **Nunca preenchido pesado.**
- **Cor:** herdam o tom de texto/acento do contexto (cobalto-400 no escuro, cobalto-500 no claro).
- **Recomendação de set:** **Lucide** (CDN `https://unpkg.com/lucide@latest`) — outline, arredondado, casa com a marca. *Substituição sugerida* — o projeto ainda não tem set próprio; trocar livremente se surgir um.
- **Sem emoji. Sem ícones religiosos explícitos.** Para "espiritual", prefira metáforas neutras (livro, marcador, onda sonora, aurora) a símbolos de culto.

---

## 7. Acessibilidade (resumo) — v1.1

Auditoria WCAG 2.1 completa com correções aplicadas em junho 2026. Referências visuais em `brand/O meu Salmo - Acessibilidade.html` e `design-system.html`.

### Regras de cor (texto)
- Texto normal ≥ 4.5:1 (AA) · texto grande (≥18pt ou ≥14pt bold) ≥ 3:1 · AAA ≥ 7:1.
- Âmbar `#C4A86A` **reprova como texto no claro** (2.1:1) — use `#8A6A28` (gold-ink, AA 4.7:1).
- **`nightMuted #353C73`** (1.9:1) e **`dayMuted #8C97D4`** (2.6:1) **nunca usar como texto** — reservados para decoração (dots, ícones inativos, separadores).
- No escuro, texto/ícones de acento: usar **cobalt-400** (4.2:1, AA grande). cobalt-500 não serve no escuro.
- Triângulo do play: **creme `#EEF0FC`** sobre cobalt = 6.2:1 (AAA).

### Correções v1.1 (junho 2026)
| Item | Antes | Depois |
|---|---|---|
| `EyebrowLabel` cor padrão (dark) | nightMuted 1.9:1 ✗ | nightText 6.9:1 ✓ AA |
| `EyebrowLabel` cor padrão (light) | dayMuted 2.6:1 ✗ | dayText 9.5:1 ✓ AAA |
| Texto reflexão bloqueada | nightText withAlpha(160) ~3.4:1 ✗ | nightText pleno 6.9:1 ✓ AA |
| Ícone reflexão bloqueada | nightText withAlpha(120) ~2.4:1 ✗ | nightText pleno 6.9:1 ✓ AA |
| CollectionCard "X SALMOS" | dotColor ~3.9:1 ✗ | bodyClr (nightText/dayText) ✓ AA |
| bodySmall/labelSmall tema | body withAlpha(166) ~3.5:1 ✗ | cor plena ✓ AA |

### Semântica / TalkBack
- Todo `GestureDetector` interativo deve ter `Semantics(label: ..., button: true)`.
- `EyebrowLabel` usa `Semantics(label: texto, excludeSemantics: true)` — evita leitura letra-por-letra (era uppercase).
- Botão de áudio: label dinâmico `"Ouvir o Salmo"` / `"Pausar áudio"`.

### Movimento reduzido
- Verificar `MediaQuery.disableAnimations` antes de qualquer animação não-essencial.
- Se ativo: `controller.value = 1.0` — conteúdo aparece imediatamente, sem animar.

---

## 8. Como usar (Claude Code)

1. Importe `colors_and_type.css` e use as variáveis (`var(--cobalt-500)`, `var(--scripture)`, classes `.ds-*`).
2. Modo padrão = noturno. Para diurno, `data-theme="day"` no container/`<html>`.
3. Consulte `ui_kits/app/` para componentes e telas de referência (home, leitura, emoções, player).
4. Siga a voz da seção 3 para toda a copy.
5. Carregue as fontes do Google Fonts (Playfair Display, Cormorant, Instrument Sans).

---

## Caveats
- **Fontes:** Playfair Display, Cormorant e Instrument Sans são do Google Fonts (não embarcadas aqui) — carregue via `<link>` ou pacote `@fontsource`.
- **Ícone:** entregue em **SVG vetorial** (`assets/app-icon.svg`) e **PNG** (`assets/app-icon-512.png`). O SVG usa as fontes da marca via texto — renderiza perfeito quando *inlined* numa página que carrega as fontes (uso típico em web/React). Como `<img>`, favicon ou submissão a loja, prefira o PNG (ou converta "Salmo" em contornos para um SVG 100% autônomo).
- **Iconografia (Lucide):** sugestão de substituição — o produto ainda não definiu um set próprio.
