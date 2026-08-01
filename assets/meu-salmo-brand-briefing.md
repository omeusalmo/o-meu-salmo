# Briefing de Identidade Visual — O meu Salmo
### Versão 2.0 · Atualizado em 2026-06-07

> **ATENÇÃO:** A fonte da verdade visual é `o-meu-salmo-design/design-system.html`.
> Este briefing documenta a identidade e os princípios. Para tokens exatos (hex, px, easing), consulte o DS.

---

## Nome canônico

**O meu Salmo** — com o artigo "O", maiúsculo. Nunca "Meu Salmo" sem o artigo.

Em interfaces: `O MEU` em Instrument Sans (eyebrow), `Salmo` em Playfair Display italic.

---

## Contexto do projeto

**O meu Salmo** é um app Android de Salmos com visual moderno, áudio narrado e curadoria por emoção — 8 coleções: Ansiedade, Sono, Gratidão, Luto, Esperança, Perdão, Louvor, Proteção. Não é "mais um app de Bíblia" — é uma *experiência* de conforto e constância espiritual, ecumênica (para católicos e evangélicos).

**Frase de essência:** "Uma pausa que devolve a você mesmo."

**O problema que resolve:** as pessoas têm fé mas não têm tempo — ou estão em alguma forma de dor emocional e buscam amparo. O app é o lugar pra isso: bonito, calmo, sem propaganda, sem ruído.

---

## 1. Sistema de cores (cobalt)

> Tokens exatos em `o-meu-salmo-design/design-system.html`. Abaixo os valores de referência.

```
ACENTO PRINCIPAL — cobalt
--cobalt-500: #2A47DD   ★ acento primário de toda identidade
--cobalt-600: #1B33B4   ← hover/pressed
--cobalt-400: #5567EA   ← variante mais clara (modo escuro)
--cobalt-300: #A29FE0   ← soft
--cobalt-100: #EEEDF8   ← background chip selecionado

MODO ESCURO (noturno — uso primário do app)
--night-base:  #080B1C   ← fundo principal
--night-plus:  #10142C   ← fundo de cards/áreas elevadas
--night-line:  #1E2348   ← divisores e bordas
--night-muted: #7080C8   ← labels metadata ≥10px, dots decorativos (5.2:1 AA)
--night-text:  #8C97D4   ← texto corrido (6.9:1 AA)
--night-cream: #EEF0FC   ← títulos, números grandes (17:1 AAA)

MODO CLARO (diurno)
--day-base:    #F5F7FE   ← fundo principal (NUNCA branco puro)
--day-plus:    #E9EDFD   ← fundo de cards
--day-line:    #D5DCF3   ← divisores
--day-muted:   #4E5899   ← labels metadata (6.2:1 AA)
--day-text:    #2E3A86   ← corpo de texto (9.5:1 AAA)
--day-title:   #0C1230   ← títulos (16.5:1 AAA)

VERSÍCULO (âmbar — somente texto de Salmo, nunca UI)
--gold:        #C4A86A   ← versículo em modo escuro
--gold-ink:    #6B4E1C   ← versículo em modo claro
```

**Regra de cor:** cobalt `#2A47DD` é o único acento de UI. Âmbar só para versículo em destaque. Sem gradientes roxo/dourado brilhante.

**Lógica emocional:** O azul-noturno `#080B1C` em modo escuro cria intimidade contemplativa — não é o azul frio de app de tecnologia. O cobalt sobre esse fundo tem presença sem agitar.

---

## 2. Tipografia

| Papel | Fonte | Especificações |
|---|---|---|
| **Display** (números de salmo, hero) | Playfair Display | 80–100px, weight 400, letter-spacing −0.025em |
| **Título de coleção / seção** | Playfair Display | 36–44px, weight 400, letter-spacing −0.015em |
| **Corpo do Salmo** (versículos) | Cormorant Italic | 17–22px, line-height 1.65 |
| **UI / Labels / Eyebrows** | Instrument Sans | 11px, weight 400, letter-spacing .34em, ALL CAPS |

**Regras invioláveis:**
- Versículos dos Salmos SEMPRE em Cormorant Italic. Nunca sans-serif para o texto sagrado.
- Números de Salmo em Playfair Display como elemento gráfico — grandes, elegantes.
- Instrument Sans para toda a UI funcional.
- Proibidos: Inter, Roboto, Arial, fontes góticas, caligrafia religiosa.

---

## 3. Logo e símbolo

**Símbolo:** Um "S" como onda fluida — stroke contínuo. Representa a inicial de "Salmo" e a forma de uma onda sonora (evoca o áudio narrado). Executado em `stroke` do `--cobalt-500` sobre fundo `--night-base`.

**Nome em lockup:** `O MEU` em Instrument Sans ALL CAPS (eyebrow role) + `Salmo` em Playfair Display italic na cor `--cobalt-500`.

**Variantes necessárias:**
- Ícone sobre fundo escuro (app icon): símbolo S em cobalt sobre rect arredondado `#080B1C`
- Ícone standalone (sem fundo): só o S em cobalt
- Lockup horizontal: ícone + nome tipográfico
- Versão para fundos claros

---

## 4. Tags de emoção — 8 coleções

| Emoção | Fundo | Texto/dot |
|---|---|---|
| Ansiedade | `#EEEDF8` | `#3D3889` / dot `#5567EA` |
| Sono | `#EAF1E6` | `#446650` / dot `#6A9A62` |
| Gratidão | `#FAF2E0` | `#7A5A18` / dot `#C99A38` |
| Luto | `#F1EBEF` | `#7A4A66` / dot `#9A6A86` |
| Esperança | `#E6EAFD` | `#1B33B4` / dot `#2A47DD` |
| Perdão | `#ECECF2` | `#5E5A82` / dot `#8480AA` |
| Louvor | `#FAF2E0` | `#7A5A18` / dot `#C99A38` (compartilha Gratidão) |
| Proteção | `#EAF1E6` | `#446650` / dot `#6A9A62` (compartilha Sono) |

Regra: tons sempre suaves, não-saturados. Cada emoção é um mundo próprio mas dentro da mesma família.

---

## 5. Padrões de UI

**Border-radius tokens:** sm 8px, md 14px, lg 22px, pill 999px. Nunca valores fora desses.

**Easing:** `cubic-bezier(.22,.61,.36,1)` padrão, `cubic-bezier(.34,1.56,.64,1)` spring para hovers e reveals.

**Ícones:** outline, traço fino arredondado. Recomendado: Lucide. Sem ícones filled pesados.

**Separadores:** sempre `1px solid --night-line / --day-line`.

---

## 6. Tom visual

Calmo, íntimo, poético. Não "gospel de banner". Não corporativo. Não app de meditação genérico (sem degradê pastel + lua).

---

## O que NÃO fazer (proibido na identidade)

1. **Cores:** Gradiente roxo ou azul royal com dourado. Branco puro como fundo. Cores saturadas vibrantes. Peach/pêssego (era identidade anterior — obsoleta).
2. **Tipografia:** Fontes góticas ou caligrafia religiosa kitsch. Inter, Roboto, Arial. Comic Sans.
3. **Símbolos:** Cruzes, pombas com aura, halos, raios de luz do céu, mãos em oração estilizadas.
4. **Tom visual:** Aspecto de editora bíblica (sépia exagerado). App de meditação genérico. Banner de culto.
5. **Layout:** Ícones preenchidos (sempre outline). Botões com gradiente. Múltiplas colunas no mobile.

---

## Fonte da verdade

`o-meu-salmo-design/design-system.html` — sempre consulte este arquivo para valores exatos antes de entregar qualquer asset visual.
