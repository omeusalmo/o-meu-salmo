# Design System × Landing Page — Auditoria de Tokens

> Gerado em 2026-06-07. Atualizado em 2026-06-07 (pós-correções). Compara `o-meu-salmo-design/design-system.html` (DS v1.1) com `Landing Page/index.html`.

---

## Legenda

| Símbolo | Significa |
|---|---|
| ✓ | Alinhado |
| ⚠️ | Divergência menor / intencional documentada |
| ✗ | Divergência — requer decisão |

---

## 1. Cores primitivas (cobalt, gold)

| Token | DS | LP | Status |
|---|---|---|---|
| cobalt-100 | `#EEEDF8` | `#EEEDF8` | ✓ |
| cobalt-200 | `#C9C7EE` | `#C9C7EE` | ✓ |
| cobalt-300 | `#A29FE0` | `#A29FE0` | ✓ |
| cobalt-400 | `#5567EA` | `#5567EA` | ✓ |
| cobalt-500 | `#2A47DD` ★ | `#2A47DD` | ✓ |
| cobalt-600 | `#1B33B4` | `#1B33B4` | ✓ |
| cobalt-700 | `#142A8C` | `#142A8C` | ✓ |
| gold | `#C4A86A` | `#C4A86A` | ✓ |
| gold-ink | `#8A6A28` | `#8A6A28` | ✓ |

---

## 2. Modo noturno (night-*)

| Token | DS | LP | Contraste DS | Contraste LP | Status |
|---|---|---|---|---|---|
| night-base | `#080B1C` | `#080B1C` | — | — | ✓ |
| night-plus | `#10142C` | `#10142C` | — | — | ✓ |
| night-line | `#1E2348` | `#1E2348` | — | — | ✓ |
| night-cream | `#EEF0FC` | `#EEF0FC` | 17:1 AAA | — | ✓ |
| night-text | `#8C97D4` | `#8C97D4` | 6.9:1 AA | — | ✓ |
| **night-muted** | `#7080C8` labels ≥10px, dots | `#7080C8` | 5.2:1 AA | 5.2:1 AA | ✓ |

**night-muted**: DS atualizado para `#7080C8` e documentado como AA-compliant para labels ≥10px e dots decorativos. LP e DS alinhados.

---

## 3. Modo diurno (day-*)

| Token | DS | LP | Contraste DS | Contraste LP | Status |
|---|---|---|---|---|---|
| day-base | `#F5F7FE` | `#F5F7FE` | — | — | ✓ |
| day-plus | `#E9EDFD` | `#E9EDFD` | — | — | ✓ |
| day-line | `#D5DCF3` | `#D5DCF3` | — | — | ✓ |
| day-title | `#0C1230` | `#0C1230` | 16.5:1 AAA | — | ✓ |
| day-text | `#2E3A86` | `#2E3A86` | 9.5:1 AAA | — | ✓ |
| **day-muted** | `#4E5899` labels ≥10px | override → `#4E5899` | 6.2:1 AA | 6.2:1 AA | ✓ |

**day-muted**: DS atualizado para aceitar `#4E5899` como texto de label/metadata. Dot decorativo documentado como `#8C97D4`. LP e DS alinhados.

---

## 4. Tokens de emoção

### Mapeamento DS → LP

| Emoção DS | Emoção LP | bg | fg DS | fg LP | dot | Status |
|---|---|---|---|---|---|---|
| Ansiedade | Ansiedade | `#EEEDF8` | `#3D3889` | `#3D3889` | `#5567EA` | ✓ |
| Paz | Sono + Proteção | `#EAF1E6` | `#4E7A52` | `#446650` | `#6A9A62` | ⚠️ fg escurecido (contraste: 4.31→5.47:1) |
| Gratidão | Gratidão + Louvor | `#FAF2E0` | `#9A7320` | `#7A5A18` | `#C99A38` | ⚠️ fg escurecido (contraste: 3.89→5.69:1) |
| Luto | Luto | `#F1EBEF` | `#7A4A66` | `#7A4A66` | `#9A6A86` | ✓ |
| Dúvida | Perdão | `#ECECF2` | `#5E5A82` | `#5E5A82` | `#8480AA` | ⚠️ nome diverge, cores iguais |

### Emoções na LP sem entrada no DS

| Var LP | Emoção | bg | fg | dot |
|---|---|---|---|---|
| `--emo-e-*` | Esperança | `#E6EAFD` | `#1B33B4` | `#2A47DD` |

> Louvor e Proteção compartilham tokens com Gratidão (`--emo-g-*`) e Sono (`--emo-p-*`) respectivamente.

### Divergências de nomenclatura

| DS | LP | Notas |
|---|---|---|
| "Paz" | "Sono" + "Proteção" | DS documentou categoria genérica; LP dividiu em duas |
| "Dúvida" | "Perdão" | Cores idênticas, nome diferente |
| — | "Esperança" | Não existe no DS |
| — | "Louvor" | Compartilha tokens de Gratidão; não documentado |

**DS precisa atualizar** a seção de emoções para refletir as 8 coleções reais.

---

## 5. Tipografia

| Uso | DS | LP | Status |
|---|---|---|---|
| Font display | Playfair Display | `var(--font-d)` = Playfair Display | ✓ |
| Font verse | Cormorant italic | `var(--font-v)` = Cormorant | ✓ |
| Font UI | Instrument Sans | `var(--font-u)` = Instrument Sans | ✓ |
| Verse body | 19–20px, lh 1.65 | `.vc-text` 19px lh 1.65 | ✓ |
| Button label | 15px w500 | `.btn` 12px w500 | ⚠️ LP usa 12px (contexto nav) |
| **Eyebrow label** | 11px, ls .34em | `.eye` 11px, ls .34em | ✓ |
| Salmo hero number | ~52px lh .88 | `.p-num` 44px lh .88 (mockup) | ⚠️ contexto diferente |

---

## 6. Border-radius

DS define 4 tokens: `sm 8px`, `md 14px`, `lg 22px`, `pill 999px`.

| Componente LP | Valor usado | Token DS | Status |
|---|---|---|---|
| `.btn` (CTA) | `999px` | pill | ✓ |
| `.chip` | `999px` | pill | ✓ |
| `.badge` | `14px` | md | ✓ |
| `.vcard` | `22px` | lg | ✓ |
| `.feat-card` | `22px` | lg | ✓ |
| `.stats-grid` | `22px` | lg | ✓ |
| `.psalm-card` | `22px` | lg | ✓ |
| `.player` | `22px` | lg | ✓ |
| `.p-btn` (mockup) | `8px` | sm | ✓ |
| `.phone` | `44px` | — | ⚠️ mockup, sem equivalente no DS |

---

## 7. Animação e movimento

| Propriedade | DS | LP | Status |
|---|---|---|---|
| Easing padrão | `cubic-bezier(.22,.61,.36,1)` easeOutCubic | `--ease: cubic-bezier(.22,.61,.36,1)` | ✓ |
| Easing spring | `cubic-bezier(.34,1.56,.64,1)` hovers/reveal | `--spring: cubic-bezier(.34,1.56,.64,1)` | ✓ |
| dur-fast | 180ms | `--dur-f: .18s` | ✓ |
| dur-default | 350ms | `--dur: .35s` | ✓ |
| dur-slow | 700ms | `--dur-s: .70s` (700ms) | ✓ |
| Reduced motion | `MediaQuery.disableAnimations` | `@media(prefers-reduced-motion:reduce)` | ✓ |

---

## 8. Sombras (box-shadow)

| Componente | DS | LP | Status |
|---|---|---|---|
| Play button | `0 12px 30px rgba(27,51,180,.30)` | `0 8px 24px rgba(27,51,180,.45)` | ⚠️ diff blur/spread/alpha |
| Botão primário | não especificado | `0 12px 36px rgba(27,51,180,.50)` hover | — |
| Chips selecionados | não especificado | `0 8px 24px rgba(8,11,28,.30)` | — |

---

## 9. Regras de acessibilidade — status LP

| Regra DS | Status LP |
|---|---|
| nightMuted/dayMuted: AA-compliant para labels ≥10px | ✓ DS e LP alinhados (`#7080C8` dark / `#4E5899` light) |
| Âmbar `#C4A86A` nunca como texto no claro | ✓ LP usa `var(--gold)` só em versículos (dark) |
| cobalt-500 nunca como texto no dark | ✓ |
| withAlpha() em texto proibido | ✓ LP usa `opacity:.48` em chip inativo (decorativo), não em texto principal |
| Eyebrow TalkBack: Semantics uppercase | N/A (web usa `aria-hidden` em `.eye`) |

---

## 10. Resumo das ações

### Tudo resolvido nesta sessão ✓

**DS atualizado:**
- ✓ 8 emoções reais documentadas (Ansiedade, Sono, Gratidão, Luto, Esperança, Perdão, Louvor, Proteção)
- ✓ "Paz" → "Sono", "Dúvida" → "Perdão"
- ✓ Esperança adicionada: `#E6EAFD / #1B33B4 / #2A47DD`
- ✓ Spring easing documentado: `cubic-bezier(.34,1.56,.64,1)`
- ✓ night-muted `#7080C8` e day-muted `#4E5899` aceitos como AA-compliant para labels ≥10px

**LP corrigida:**
- ✓ Eyebrow `.eye`: 11px / .34em
- ✓ `.psalm-card` border-radius: 22px (lg)
- ✓ `.player` border-radius: 22px (lg)
- ✓ `.p-btn` border-radius: 8px (sm)
- ✓ `--dur-s`: .70s (700ms)

### Pendências abertas:
- **favicon.png + apple-touch-icon.png**: arquivos precisam ser fornecidos (derivar do ícone do app)
- **og-image.png** (1200×630): ainda não existe — necessário para compartilhamento social
- **Play Store URL**: quando publicado, substituir `href="#dl"` pelos botões e `installUrl` no schema
