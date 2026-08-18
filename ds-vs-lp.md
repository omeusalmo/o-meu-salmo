# Design System × Landing Page: Auditoria de Tokens

> Gerado em 2026-06-07. Atualizado em **2026-08-17** (propagação do DS v1.2 + auditoria de contraste WCAG).
> Compara `o-meu-salmo-design/design-system.html` (DS **v1.2**) com `docs/index.html` (a LP publicada; `Landing Page/` é pasta legada).

## TL;DR

**A LP está alinhada com o DS v1.2.** Duas rodadas: propagação de tokens, depois as quatro regras novas de estado e acessibilidade. Auditoria WCAG com script próprio no DOM real, nos dois temas: **zero reprovações de texto ou componente, zero regressões.**

| Verificação | Antes | Depois |
|---|---|---|
| Pares de cor reprovando (escuro) | 20 | 0 reais, 11 isentos |
| Pares de cor reprovando (claro) | 24 | 0 reais, 11 isentos |
| Focáveis com foco visível | 20 de 21 | **21 de 21** |
| Decoração exposta ao leitor de tela | 39 elementos | **0** |
| Estado comunicado por opacidade | chip do seletor | **nenhum** |

Os 11 "isentos" são números fantasma decorativos, o estado inicial da revelação por scroll, e o logotipo do rodapé (exceção de logotipo da WCAG 1.4.3).

O que ainda diverge, e é decisão consciente:
1. **Display grande continua em `cobalt-400`** (títulos itálicos de 28px a 74px). Passa AA de texto grande. O designer ratificou manter.
2. **Chips estáticos do hero mantêm o preenchimento pastel por emoção.** Não são chips de seleção, não têm estado, e passam (5.47:1 a 5.96:1). Ficou uma diferença visual entre eles e os chips do seletor, que agora são de contorno. Vale um olhar do designer.

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
| cobalt-300 | `#A29FE0` | `#A29FE0` | ✓ (tinte da rampa, **não é acento**) |
| **cobalt-350** ★ novo v1.2 | `#7C8BF0` | `#7C8BF0` | ✓ acento de TEXTO/ícone no escuro |
| cobalt-400 | `#5567EA` | `#5567EA` | ✓ existe, mas ⚠️ proibido como texto normal no escuro (3.64:1) |
| cobalt-500 | `#2A47DD` ★ | `#2A47DD` | ✓ |
| cobalt-600 | `#1B33B4` | `#1B33B4` | ✓ |
| cobalt-700 | `#142A8C` | `#142A8C` | ✓ |
| gold | `#C4A86A` | `#C4A86A` | ✓ |
| gold-ink | `#6B4E1C` | `#6B4E1C` | ✓ | (escurecido de #8A6A28 → AAA 7.2:1, a11y público +velho) |

---

## 2. Modo noturno (night-*)

| Token | DS | LP | Contraste DS | Contraste LP | Status |
|---|---|---|---|---|---|
| night-base | `#080B1C` | `#080B1C` | — | — | ✓ |
| **night-plus** (v1.2) | `#151A39` (era `#10142C`) | `#151A39` | 1.15:1 vs base | idem | ✓ propagado |
| **night-line** (v1.2) | `#323A77` (era `#1E2348`) | `#323A77` | 1.62:1 vs superfície | idem | ✓ propagado |
| night-cream | `#EEF0FC` | `#EEF0FC` | 17:1 AAA | 14.94:1 sobre superfície | ✓ |
| night-text | `#8C97D4` | `#8C97D4` | 6.9:1 AA | 6.97:1 base / 6.05:1 superfície | ✓ |
| **night-muted** | `#7080C8` labels ≥10px, dots | `#7080C8` | 5.2:1 AA | 5.22:1 base / **4.53:1 superfície** | ⚠️ ver abaixo |
| **night-accent-txt** (v1.2) | `#7C8BF0` | `var(--accent-txt)` = `#7C8BF0` | 5.50:1 AA | 5.50:1 superfície / 6.33:1 base | ✓ |

**night-muted sobre a superfície v1.2: 4.53:1.** Passa AA por 0.03. A superfície ficou mais clara (`#10142C` → `#151A39`) e comeu quase toda a folga: antes eram 4.84:1. Consequências práticas na LP:

- Nenhum tinte de fundo pode ficar **mais claro** que `#151A39` sob texto `night-muted`. O hover de `.stat-item` era `#161A38` (mais claro), o que reprovaria; foi invertido para `#10142C`, escurecendo, que é o mesmo gesto que o tema claro já usava.
- O "tinte de seleção `#20264C`" do DS **reprova** com `night-muted` (3.89:1). Serve para `cobalt-350` (4.72:1), não para rótulos muted. Vale checar se o app cai nessa.

---

## 3. Modo diurno (day-*)

| Token | DS | LP | Contraste DS | Contraste LP | Status |
|---|---|---|---|---|---|
| day-base | `#F5F7FE` | `#F5F7FE` | — | — | ✓ |
| **day-plus** (v1.2) | `#E1E6FC` (era `#E9EDFD`) | `#E1E6FC` | 1.16:1 vs base | idem | ✓ propagado |
| **day-line** (v1.2) | `#A8B6E6` (era `#D5DCF3`) | `#A8B6E6` | 1.61:1 vs superfície | idem | ✓ propagado |
| day-title | `#0C1230` | `#0C1230` | 16.5:1 AAA | 14.78:1 sobre superfície | ✓ |
| day-text | `#2E3A86` | `#2E3A86` | 9.5:1 AAA | 8.19:1 sobre superfície | ✓ |
| **day-muted** | `#4E5899` labels ≥10px | override → `#4E5899` | 6.2:1 AA | 6.17:1 base / 5.32:1 superfície | ✓ |
| **day-accent-txt** (v1.2) | `#2A47DD` | `var(--accent-txt)` = `#2A47DD` | 5.56:1 AA | 5.56:1 superfície / 6.45:1 base | ✓ |

No claro a superfície escureceu, então todo texto escuro **ganhou** contraste. Nenhum par piorou.

---

## 3b. Acento de texto × acento de preenchimento (regra nova do v1.2)

O DS separou dois papéis que antes eram o mesmo token. A LP agora tem os dois:

| Papel | Token LP | Escuro | Claro | Onde é usado na LP |
|---|---|---|---|---|
| Texto e ícone de acento | `--accent-txt` | `cobalt-350` `#7C8BF0` | `cobalt-500` `#2A47DD` | `.ph-wm .sa`, `.kv-n` |
| Preenchimento sólido | `--accent-fill` / `--accent` | `cobalt-500` `#2A47DD` | `cobalt-500` | `.btn`, `.skip-link`, `.play-btn`, `.p-btn` |
| Foreground sobre preenchimento | `--on-accent` `#FFFFFF` | igual | igual | rótulo do `.btn` e do `.skip-link` |

**`--on-accent` é uma adição da LP.** O DS fala em "creme sobre cobalt-500 = 6.08:1". Na LP o rótulo do botão vinha de `var(--tx)`, que no tema claro vira o título escuro `#0C1230` e dava **2.66:1** sobre o cobalt-500. Fixar em branco resolve nos dois temas (6.90:1) e sobrevive ao hover.

**Hover de preenchimento: divergência aberta.** `.btn:hover` e `.play-btn:hover` clareavam para `cobalt-400`, o que dá 4.10:1 com creme e reprova. O DS v1.2 só define o repouso e proíbe clarear, não define o hover. A LP passou a **escurecer para `cobalt-600`** (9.64:1). Precisa de aval do designer e, se aprovado, de um token de estado no DS.

---

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
| nightMuted/dayMuted: AA para labels ≥10px | ✓ alinhados, mas o dark caiu para 4.53:1 sobre a superfície v1.2 (folga de 0.03) |
| Âmbar `#C4A86A` nunca como texto no claro | ✓ **corrigido em 2026-08-17**. `.p-verse` do mockup usava `var(--gold)` fixo e sobrevivia ao tema claro dando 1.97:1. Agora usa `var(--scripture)`, que vira `gold-ink` no claro (6.20:1) |
| cobalt-500 nunca como texto no dark | ✓ |
| cobalt-400 nunca como texto normal no dark (v1.2) | ✓ para texto pequeno. ⚠️ display grande (44px a 74px) segue no 400, ver seção 11 |
| cobalt-350 nunca como preenchimento sólido (v1.2) | ✓ nenhum preenchimento da LP usa 350 |
| withAlpha() em texto proibido | ✓ `opacity` saiu do aviso de cookies (era .6, dava 2.58:1) e do chip do seletor (era .48, dava 1.99:1). Segue só no logotipo do rodapé (.5), isento por WCAG 1.4.3 |
| Estado nunca é opacidade (v1.2) | ✓ **corrigido**. Nenhum estado da LP depende de opacidade. Ver 10b |
| Preenchimento escurece, primeiro plano clareia (v1.2) | ✓ escada 500 / 600 / 700 em `.btn` e `.play-btn` |
| Decoração sai da árvore de acessibilidade (v1.2) | ✓ **corrigido**. 39 elementos saíram. Ver 10b |
| Foco de teclado: 2px, 2px de deslocamento (v1.2) | ✓ **corrigido**. 21 de 21 focáveis. O skip link estava sem foco visível |
| Eyebrow TalkBack: Semantics uppercase | N/A (web usa `aria-hidden` em `.eye`) |
| Alvo de toque 48dp (v1.2) | ⚠️ não auditado nesta rodada. `#theme-btn` tem 34×34px de desenho e nenhum padding de área. Fica para a próxima |
| Fonte do sistema até 2.0x (v1.2) | N/A na web, mas o equivalente (zoom de 200% e `text-size-adjust`) não foi auditado |

**Bordas.** `--border` sobre a superfície dá 1.62:1 no escuro e 1.61:1 no claro, exatamente o alvo do DS v1.2 (subiu de 1.17:1). Não é reprovação: bordas de card são decorativas, e o único controle que depende de borda (`#theme-btn`, 1.87:1 sobre o fundo) é identificado pelo ícone dentro dele, que dá 6.05:1.

---

## 10. Propagação do DS v1.2 na LP (2026-08-17)

Auditoria feita com script próprio que instrumenta o DOM real no Chrome headless, resolve o fundo efetivo subindo a árvore, trata `opacity` como grupo de composição e calcula a razão WCAG 2.1 de cada par que aparece na página. Rodada nos dois temas.

| Onde | Antes escuro | Antes claro | Depois escuro | Depois claro | Correção |
|---|---|---|---|---|---|
| `.ph-wm .sa` "Salmo" no mockup, 18px | 3.90 ✗ | 3.99 ✗ | **5.50** ✓ | **5.56** ✓ | `cobalt-400` → `--accent-txt` |
| `.kv-n` numeração do player, 10px | 4.20 ✗ | 4.35 ✗ | **6.33** ✓ | **6.45** ✓ | `--accent-lt` → `--accent-txt` |
| `.btn` "Baixar grátis", 11px e 13px | 6.08 ✓ | 2.66 ✗ | **6.90** ✓ | **6.90** ✓ | `var(--tx)` → `--on-accent` |
| `.skip-link` | 6.08 ✓ | 2.66 ✗ | **6.90** ✓ | **6.90** ✓ | `var(--tx)` → `--on-accent` |
| `.btn:hover` / `.play-btn:hover` | 4.10 ✗ | 4.10 ✗ | **9.64** ✓ | **9.64** ✓ | fundo `cobalt-400` → `cobalt-600` |
| `.p-verse` versículo no mockup, 13px | 7.90 ✓ | 1.97 ✗ | **7.39** ✓ | **6.20** ✓ | `var(--gold)` → `var(--scripture)` |
| Aviso de cookies no rodapé, 10px | 2.58 ✗ | 2.64 ✗ | **5.22** ✓ | **6.17** ✓ | removida `opacity:.6` inline |
| Chips do seletor, rótulo 15px (pior caso) | 2.82 ✗ | 1.99 ✗ | **5.21** ✓ | **4.80** ✓ | `opacity` .48 → .94, hover .78 → 1 |
| `.stat-item:hover` rótulo muted | 4.53 ✓ | 5.00 ✓ | **4.84** ✓ | **5.00** ✓ | tinte `#161A38` → `#10142C` |

Placar: **20 reprovações no escuro e 24 no claro antes, 11 e 11 depois, zero regressões.** As 11 que sobram são todas isentas:

| Item | Razão | Por que fica |
|---|---|---|
| `.ghost`, `.dl-ghost`, `.ccard .gn` (6 cartões) | 1.01 a 1.14 | Números fantasma em `opacity` .03 a .09. Decoração pura, isenta por WCAG 1.4.3 |
| `.sc-text span` | 1.14 | Estado inicial da revelação por scroll. Chega a `opacity:1` quando o texto entra |
| `.logo .sa` e `.logo .om` do rodapé | 1.89 e 2.55 | Logotipo em `opacity:.5`. Exceção de logotipo da 1.4.3 |

---

## 10b. Segunda rodada: as quatro regras novas do v1.2 (2026-08-17)

O designer bateu o martelo nos itens abertos. Duas decisões viraram trabalho na LP, uma foi ratificada e uma virou regra geral.

### Chip de seleção: a opacidade saiu inteira

Implementado conforme "Chip de seleção · estado sem opacidade" da seção 5 do DS. Os 8 botões do `#picker-chips` perderam o `style="background:var(--emo-X-bg);color:var(--emo-X-fg)"` inline; o estado agora vem do CSS. O ponto colorido da emoção continua, é ele que carrega a identidade.

| Canal | Selecionado | Não selecionado |
|---|---|---|
| Fundo | `--chip-sel-bg` (acento a 10% escuro / 8% claro) | transparente |
| Borda | 1px `--chip-sel-bd` (acento a 63%) | 0.5px `--border` |
| Rótulo | `--accent-txt`, **w500** | `--text`, w400 |
| Lift | `translateY(-2px)` | nenhum |

Contraste do rótulo medido, e bate com o DS na casa decimal:

| | Escuro | DS | Claro | DS |
|---|---|---|---|---|
| Selecionado | **5.65:1** | 5.65 | **5.71:1** | 5.71 |
| Não selecionado | **6.97:1** | 6.97 | **9.50:1** | 9.50 |

Borda do selecionado contra o fundo da página: **3.39:1** escuro e **3.22:1** claro, acima dos 3:1 de grafismo. O DS registra 3.17 e 3.04; a diferença é o fundo de referência (o DS mediu contra a superfície do card onde a amostra está, a LP mede contra o fundo real da seção). Contra o próprio preenchimento do chip dá 3.02:1 escuro e 2.85:1 claro, mas a borda não é o único sinal: são quatro canais simultâneos mais `aria-pressed`.

Hover do não selecionado, que antes era `opacity:.78`, virou borda em `--accent-txt` mais rótulo em `--tx`. Mesmo padrão que `#theme-btn:hover` e `.faq-item:hover` já usavam.

### Foco de teclado: tinha, e um estava quebrado

A suspeita estava meio certa. A LP **tinha** um `:focus-visible` global, mas `.skip-link:focus{outline:none}` vencia por especificidade e apagava o foco justamente do **primeiro alvo do Tab**. Medido elemento a elemento com `.focus()` programático e leitura do `outlineStyle` computado: 20 de 21 focáveis com contorno, o skip link com `outline-style: none`.

Corrigido: `outline:none` removido, e a regra global passou para o token do DS.

```css
:focus-visible{outline:2px solid var(--accent-txt);outline-offset:2px;}
```

Antes era `2px var(--accent-lt)` com 3px de deslocamento. Agora são **21 de 21** nos dois temas, com o contorno a 6.33:1 (escuro) e 6.45:1 (claro) contra o fundo da página, bem acima dos 3:1.

### Hover ratificado, e a escada foi completada

`cobalt-600` no hover confirmado. A LP não tinha `:active` nem `disabled` em botão nenhum, então **no toque o CTA principal não dava retorno algum**. Adicionado o degrau que faltava:

| Estado | Token | Contraste com o branco |
|---|---|---|
| Repouso | `cobalt-500` | 6.90:1 |
| Hover (só ponteiro) | `cobalt-600` | 9.64:1 |
| Pressed | `cobalt-700` | **12.07:1** |

Vale para `.btn` e `.play-btn`. Não há estado desabilitado na LP, nada a alinhar ali.

### Decoração fora da árvore de acessibilidade

Varredura na página inteira, não só nos três números. **39 elementos decorativos estavam sendo anunciados; agora são 0.**

| O que | Quantos | Como |
|---|---|---|
| Números fantasma `.ghost`, `.dl-ghost`, `.ccard .gn` | 10 | `aria-hidden="true"` |
| Pontos de emoção (hero, coleções, card gerado por JS) | 17 | `aria-hidden="true"` |
| Numeração `.ix-n` "01" a "04" | 4 | `aria-hidden="true"` |
| Cursor custom, divisor `.sb-deco`, barra do player | 3 | `aria-hidden="true"` |
| Mockup do celular `#hero-phone` | 1 subárvore | `role="img"` + `aria-label` |

O mockup merecia tratamento diferente. Ele reproduz a tela do app em DOM, e o leitor de tela recitava a barra de status falsa ("9:41 5G"), a data falsa, a marca d'água e um "Ler o salmo" que não é botão. Com `role="img"` mais `aria-label` a subárvore para de ser lida item a item e vira uma imagem com descrição, sem perder a informação de que ali está a tela do app. Isso resolveu de uma vez `.pstat`, `.ph-wm`, `.p-btn` e o ícone de engrenagem sem nome acessível.

---

## 10c. Os quatro itens levantados na primeira rodada: status

1. **Display grande em `cobalt-400`.** `.hero-hl em`, `.picker-hl em`, `.cols-hl em`, `.audio-hl em`, `.sb-hl em`, `.feat-hl em`, `.dl-hl em`, `.faq-hl em`, `.pc-num em`, `.p-num em`, `.stat-n`, `.plyr-psalm em`. De 28px a 74px, entre 3.64:1 e 4.35:1, passam AA de texto grande. **RATIFICADO: fica como está.**
2. ~~Nível de esmaecimento do chip não selecionado~~ **RESOLVIDO por remoção.** A opacidade saiu inteira, ver 10b. O `.94` que eu tinha posto saiu junto com o `.48` original.
3. ~~Hover de preenchimento em `cobalt-600`~~ **RATIFICADO** e virou regra do sistema: preenchimento só escurece, primeiro plano só clareia. Escada completada com `:active` em `cobalt-700`.
4. ~~`aria-hidden` nos números fantasma~~ **RESOLVIDO e generalizado.** Virou varredura da página inteira, ver 10b.

### Aberto agora

- **Chips estáticos do hero** seguem com preenchimento pastel por emoção enquanto os do seletor viraram de contorno. Não é defeito (passam de 5.47:1 a 5.96:1) e eles não têm estado, mas a diferença visual entre os dois grupos é perceptível. Decisão de design.
- **Alvo de toque 48dp** não auditado. `#theme-btn` desenha 34×34px sem área extra.
- **Zoom de 200%** (equivalente web da fonte do sistema a 2.0x) não auditado.

---

## 11. Resumo das ações (2026-06-07)

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

### Pendências daquela rodada, status hoje:
- ~~favicon.png + apple-touch-icon.png~~ ✓ existem em `docs/`
- ~~og-image.png (1200×630)~~ ✓ existe em `docs/`
- ~~Play Store URL~~ ✓ app em produção desde 2026-08-13, botões apontam para a Play

### Pendências abertas hoje (2026-08-17):
- Aval do designer nos 4 itens da seção 10 ("ficou de fora")
- Auditoria de alvo de toque 48dp e de zoom 200% na LP (regras novas do DS v1.2)
- Seção de emoções do DS ainda usa "Paz" e "Dúvida"; a LP usa as 8 coleções reais
