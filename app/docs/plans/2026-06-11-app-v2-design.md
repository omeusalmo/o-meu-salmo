# App V2 — "Liturgia Digital" Design

## Overview

V2 do app O meu Salmo em `app-v2/` (cópia independente de `app/`), portando o conceito
da LP V2 (`docs/v2/`): starfield, ambient glow por emoção, revelação palavra a palavra,
narração karaokê e interlúdio de respiração. Tokens do DS inalterados.
Android primeiro; nada de platform channels novos — iOS-ready por construção.

## User Stories

- Como usuário ansioso, abro o app e a tela respira comigo (starfield calmo, entrada suave).
- Como usuário, vejo o versículo-âncora surgir palavra por palavra — leitura contemplativa.
- Como usuário ouvindo a narração, o versículo ativo acende em âmbar (karaokê).
- Como usuário em crise, acesso "Respirar" da Home: ciclo 4-1-4 com Salmo 46:10.
- Como usuário, ao navegar entre coleções a luz ambiente muda para a cor da emoção.

## Decisões consultadas nos agentes

- **designer:** cores via `AppColors.*`; spacing sp1–sp12; radius sm/md/lg/pill;
  animações atrás de `MediaQuery.disableAnimations`; Semantics; cobalt único acento,
  âmbar só versículo; sem iconografia religiosa; dark+light.
- **tech-lead-app:** Riverpod, go_router, tokens em `app_theme.dart` primeiro.

## Clean Architecture

### Domain/Data
Sem mudança — modelos, repositório e providers herdados de V1.
Única adição: estimativa de versículo ativo (função pura, derivada de
`AudioState.position/duration` + pesos por tamanho de texto). Vive em
`features/salmos/verse_sync.dart` (presentation-side, sem IO).

### Presentation (novo/alterado)
- `shared/widgets/starfield_background.dart` — CustomPainter, ~70 partículas,
  drift + twinkle, dark/light aware, desliga com `disableAnimations`.
- `shared/widgets/ambient_glow.dart` — gradiente radial animado (cor da emoção).
- `shared/widgets/word_reveal_text.dart` — versículo palavra a palavra (1 controller,
  Interval por palavra).
- `shared/widgets/staggered_entrance.dart` — fade+rise com delay indexado (= `.rv` da LP).
- `shared/widgets/breathing_circle.dart` — círculo 4-1-4 (Inspire/Segure/Expire).
- `features/respirar/respirar_screen.dart` — rota `/respirar`, verso Salmo 46:10.
- Home V2 — starfield + entrada staggered + word-reveal no versículo + card "Respirar".
- Coleções V2 — lista staggered + ambient glow + numeral fantasma nos cards.
- Leitura V2 — karaokê: versículo ativo pleno (âmbar), demais esmaecidos
  (cor plena, sem withAlpha em texto → usa cores muted do DS), só quando tocando.
- Router — transição fade-through calma entre rotas push.

## State

- `verseSyncProvider` (Provider derivado de `audioPlayerProvider`) → índice do
  versículo ativo. Sem estado novo persistido.
- Respirar: estado local (AnimationController + fase), nada global.

## Testing Plan

- Unit: `verse_sync` (estimativa de índice por posição/pesos).
- Herdados: testes existentes de V1 devem continuar verdes (`flutter test`).
- `flutter analyze` limpo antes de push.

## Infra

- `app-v2/assets/audios/` fora do git (62 MB já versionados em `app/`);
  `setup.sh` sincroniza de `../app/assets/audios`.
- `applicationId` inalterado (Firebase/google-services validam o pacote).
  V1 e V2 não coexistem instalados — testar um por vez.

## Dependencies

Nenhum pacote novo. Tudo com Flutter stdlib + pacotes já presentes.
