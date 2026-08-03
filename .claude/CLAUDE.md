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
o-meu-salmo/                      ← raiz do git (github.com/omeusalmo/o-meu-salmo)
├── app/                          ← Flutter app V2 (Dart) — promovida em 2026-06-12
│   ├── lib/                      ← código Dart (features, core, data, shared)
│   ├── android/                  ← config Android + signing
│   ├── assets/                   ← salmos.json, imagens, áudios
│   ├── docs/                     ← (legado — não é o GH Pages ativo)
│   └── test/                     ← testes + testadores-meu-salmo.md
├── Landing Page/                 ← pasta legada (arquivos movidos para docs/)
├── archive/                      ← V1 arquivada em 2026-06-12 (app-v1/, lp-v1/)
├── o-meu-salmo-design/
│   ├── design-system.html        ← FONTE DA VERDADE visual ★
│   ├── SKILL.md                  ← skill de design do projeto
│   ├── brand/                    ← identidade visual, ícone, acessibilidade
│   ├── docs/
│   │   ├── ux-writing-voice-and-tone.md
│   │   └── arquitetura-informacao.md
│   └── ui_kits/app/
├── assets/
│   ├── plano-de-negocios-app-salmos.md
│   ├── meu-salmo-brand-briefing.md
│   ├── roadmap-app-salmos.md
│   ├── roadmap-gerente.md        ← roadmap pós-lançamento para agente gerente
│   └── reflexoes-salmos.md       ← fonte das reflexões dos 150 salmos
├── audio_testes/                 ← testes de vozes TTS (salmo 23, 30 vozes)
├── play-store/                   ← kit de loja: export/ (bundle upload) + listing/aso-copy.md (textos ★) + data-safety-form.md
│                                   ⚠️ screenshots em export/ são de 2026-06-12 (refazer antes da produção)
├── docs/                         ← GitHub Pages (main /docs) → omeusalmo.com.br
│   ├── index.html                ← landing page V2 (HTML/CSS/JS inline) ★
│   ├── robots.txt
│   ├── sitemap.xml
│   ├── llms.txt
│   └── privacy_policy.html
├── privacy_policy.html           ← cópia root (canônico em docs/)
├── gerar_audios.py               ← script geração de áudios TTS
└── ds-vs-lp.md                   ← auditoria DS × LP (tokens, divergências)
```

## Git e deploy

- **Repo:** `github.com/omeusalmo/o-meu-salmo` (raiz = `o-meu-salmo/`)
- **GH Pages:** `main /docs` → `https://omeusalmo.github.io/o-meu-salmo/`
- **Signing:** `app/android/key.properties` (gitignored) + keystore em `~/keystores/omeusalmo.jks`
- **Workflow:** qualquer mudança → push para `main`. Todos os tech leads seguem esta regra.

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
| Versículo (gold) | `#C4A86A` | `#6B4E1C` |

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
| `marketing` | Copy LP, validação ASO, conteúdo orgânico | gerente |
| `analista-dados` | Firebase Analytics, Play Console, OKRs/KPIs | gerente |
| `designer` | Design system, identidade visual | gerente |

Qualquer mudança no DS deve ser propagada pelos 3 tech leads nos seus domínios.

## Tom de voz

Íntimo, sóbrio, poético. Sem performático religioso. Fala direta com quem está vulnerável. "você". Sem emoji. Sem jargão de marketing dentro do produto.