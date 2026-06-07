# O meu Salmo — Contexto do Projeto

App Android de Salmos com curadoria por emoção. Solo founder: Jeff Silva (CEO).

## O produto

- 150 Salmos em 8 coleções emocionais: Ansiedade, Sono, Gratidão, Luto, Esperança, Perdão, Louvor, Proteção
- Leitura + áudio narrado + reflexão por Salmo
- Favoritos salvos offline, sem anúncios, gratuito (MVP)
- Público: cristãos brasileiros (católicos e evangélicos) em momentos de vulnerabilidade
- Plataforma: Android (Google Play). iOS: futuro.

## Mapa de arquivos

```
o-meu-salmo/
├── app/                          ← Flutter app (Dart)
├── Landing Page/
│   ├── index.html                ← landing page (HTML/CSS/JS inline)
│   ├── robots.txt
│   ├── llms.txt
│   └── privacy_policy.html
├── o-meu-salmo-design/
│   ├── design-system.html        ← FONTE DA VERDADE visual ★
│   ├── SKILL.md                  ← skill de design do projeto
│   ├── docs/
│   │   ├── ux-writing-voice-and-tone.md
│   │   └── arquitetura-informacao.md
│   └── ui_kits/app/
├── assets/
│   ├── plano-de-negocios-app-salmos.md
│   ├── meu-salmo-brand-briefing.md
│   └── roadmap-app-salmos.md
└── ds-vs-lp.md                   ← auditoria DS × LP (tokens, divergências)
```

## Design System — regras essenciais

**Fonte da verdade:** `o-meu-salmo-design/design-system.html`

| Token | Escuro | Claro |
|---|---|---|
| Acento (cobalt-500) | `#2A47DD` | `#2A47DD` |
| Acento claro (cobalt-400) | `#5567EA` | — |
| Superfície | `#10142C` | `#E9EDFD` |
| Texto | `#8C97D4` | `#2E3A86` |
| Título | `#EEF0FC` | `#0C1230` |
| Muted/label | `#7080C8` | `#4E5899` |
| Versículo (gold) | `#C4A86A` | `#8A6A28` |

Fontes: Playfair Display (display/número), Cormorant italic (versículo), Instrument Sans (UI/label).

Border-radius tokens: sm 8px, md 14px, lg 22px, pill 999px.

Easing: `cubic-bezier(.22,.61,.36,1)` padrão, `cubic-bezier(.34,1.56,.64,1)` spring.

## Time de agentes

| Agente | Escopo | Reporta para |
|---|---|---|
| `gerente` | Negócio, estratégia, coordenação | Jeff (CEO) |
| `tech-lead-app` | Flutter app, código, DS no app | gerente |
| `tech-lead-lp` | Landing page, SEO/GEO/CRO | gerente |
| `tech-lead-loja` | Google Play listing, ASO | gerente |

Qualquer mudança no DS deve ser propagada pelos 3 tech leads nos seus domínios.

## Tom de voz

Íntimo, sóbrio, poético. Sem performático religioso. Fala direta com quem está vulnerável. "você". Sem emoji. Sem jargão de marketing dentro do produto.