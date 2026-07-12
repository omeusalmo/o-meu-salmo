# Prompt — Claude Design: Imagens dos Anúncios (O meu Salmo)

> **Como usar:** cole este prompt numa conversa com o Claude (com skill de design/frontend)
> pra gerar as artes dos posts patrocinados em HTML/CSS → screenshot → PNG.
> Funciona em par com `prompt-opus-campanhas-pagas.md` (as copies vêm de lá).
> Referências visuais reais: `play-store/export/` (screenshots emoldurados) e
> `o-meu-salmo-design/design-system.html` (fonte da verdade).

---

## PROMPT (copiar daqui pra baixo)

Você é o designer do app **O meu Salmo** e vai criar as imagens de anúncios pagos (Meta Ads: feed, stories/reels) seguindo rigorosamente o design system do produto. Gere cada peça como HTML/CSS auto-contido (Google Fonts ok) pronto pra screenshot no tamanho exato — mesma técnica dos screenshots da loja.

### Design System (fonte da verdade — não inventar fora disso)

**Cores (tema escuro — padrão das peças):**
| Token | Hex | Uso |
|---|---|---|
| night-base | `#080B1C` | fundo |
| night-plus | `#10142C` | superfície/cards |
| cobalt-500 | `#2A47DD` | acento, botões |
| cobalt-400 | `#5567EA` | acento claro, itálicos de marca |
| night-cream | `#EEF0FC` | títulos |
| night-text | `#8C97D4` | texto de apoio |
| night-muted | `#7080C8` | eyebrow/labels |
| gold | `#C4A86A` | versículos (sempre gold, sempre Cormorant itálico) |

**Tipografia (Google Fonts):**
- Playfair Display — títulos/display, números de salmo
- Cormorant (itálico) — versículos bíblicos, SEMPRE
- Instrument Sans — UI, eyebrows (caps + letter-spacing largo), corpo

**Estética:** calma, editorial, muito respiro. Border-radius 8/14/22px. Fundo com leve gradiente radial cobalt sutil (tipo céu noturno) permitido. Textura de estrelas/pontos sutil permitida. NADA de: stock photo, mãos orando genéricas, raios de luz kitsch, dourado brilhante, poluição visual.

### Identidade nas peças

- Logo/lockup: "O MEU" (Instrument Sans, caps, tracking largo, muted) sobre "Salmo" (Playfair itálico, cream ou cobalt-400)
- Bookmark/marcador de fita no topo = elemento de marca (ver ícone do app)
- Tagline disponível: "Uma pausa que devolve a você mesmo."
- Frase-âncora: "Para cada emoção, o Salmo certo."
- Badge de loja: "Disponível no Google Play" discreto (texto ou badge oficial)

### Formatos a gerar (cada conceito nos 3)

1. **Feed quadrado** — 1080×1080
2. **Stories/Reels** — 1080×1920 (zona segura: nada importante nos 250px do topo e 340px do rodapé)
3. **Feed retrato** — 1080×1350

### Conceitos (1 peça por conceito × 3 formatos = 12 artes)

**C1 · Ansiedade → versículo**
Versículo central em Cormorant gold: "Lança o teu cuidado sobre o Senhor." Eyebrow: ANSIEDADE. Sub: "Salmos escolhidos para esse momento." Mock do app opcional pequeno.

**C2 · Sono/Noite**
Céu noturno profundo, versículo: "Em paz me deito e logo adormeço." Eyebrow: PARA A NOITE DIFÍCIL. Headline Playfair: "O silêncio que fala."

**C3 · Produto/Screenshot**
Screenshot real do app emoldurado em device (usar estilo de `play-store/export/s2-home.png`), headline: "Para cada emoção, o Salmo certo." Bullets curtos: 150 Salmos narrados · offline · grátis · sem anúncios.

**C4 · Respirar**
Círculo de respiração (anel fino cobalt em fundo night), palavra INSPIRE no centro, versículo do Salmo 46: "Aquietai-vos, e sabei que eu sou Deus." Headline: "Um minuto de pausa."

### Regras de anúncio

- Texto na imagem ≤ 20% da área (regra prática Meta) — headline curta, versículo como elemento visual
- Contraste AA no mínimo; testar legibilidade em tela pequena
- Sem emoji nas artes; sem CTA agressivo na imagem (CTA fica no botão do anúncio)
- Cada arte deve funcionar SEM o texto do anúncio em volta (autossuficiente)

### Entrega

1. Um arquivo HTML por peça, nomeado `ad-<conceito>-<formato>.html` (ex: `ad-c1-ansiedade-1080x1080.html`), tamanho fixo exato do formato
2. Screenshot de cada um em PNG (mesma técnica dos screenshots da loja: Chrome headless `--window-size` ou DevTools capture)
3. Salvar em `marketing/ads/` no projeto
4. Ao final: tabela índice com peça × formato × arquivo

Antes de gerar tudo, mostre 1 conceito (C1 no 1080×1080) pra aprovação de direção. Depois produza o restante.
