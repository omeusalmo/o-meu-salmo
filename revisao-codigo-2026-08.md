# Revisão de código — O meu Salmo (app/lib/)

**Status:** 15 de 16 achados resolvidos (commits `6a24b86`, `fb4a8c3`, `411bde6`, `57fc7f7`). Validado com 2ª auditoria independente (mesmas skills, do zero) — achou e fechou 2 lacunas que a 1ª rodada deixou passar (ver seção "Validação" no fim). Só #2/#9 (i18n) seguem adiados por decisão consciente, sem inglês no roadmap. #15 é informativo, sem fix de código.

**Data:** 2026-08-07
**Método:** audit read-only via skills Claude Code (`owasp-security`, `detect-code-smells`, `anti-patterns-catalog`, `review-solid-clean-code`, `performance-anti-patterns`, `refactoring-decision-matrix`, `i18n-l10n-patterns`) sobre os 44 arquivos Dart em `app/lib/` (~7700 linhas). Nenhuma edição foi feita.

## TL;DR

- **16 achados reais**, nenhum Crítico. **4 Altos, 8 Médios, 4 Baixos.**
- Os 2 achados mais importantes não são bugs de hoje, são **risco de custo futuro**: (1) app coleta dados de uso por padrão (opt-out) mesmo processando categoria sensível LGPD (emoção/religião), e (2) app não tem NENHUMA infraestrutura de tradução, apesar do padrão do projeto ser pt/en — virar bilíngue hoje = reescrever 44 arquivos na mão.
- Achado mais "custoso em manutenção": existe design system pronto (`AppTheme`, `BuildContextX`) que quase ninguém usa. 126 chamadas de fonte e dezenas de decisões de cor claro/escuro foram reescritas na mão espalhadas por 20+ arquivos em vez de reusar o que já existe.
- Segurança clássica (injeção, autenticação, controle de acesso) não achou quase nada — app é 100% offline e sem login. Esperado, bom sinal.

## O que cada skill encontrou

| Skill | Resultado |
|---|---|
| `owasp-security` | 2 achados (privacidade LGPD, exposição de config Firebase — informativa). |
| `detect-code-smells` | 6 achados (duplicação de cor/tema, botão duplicado, arquivos grandes, método longo, mapeamento de coleção frágil, dead code). |
| `anti-patterns-catalog` | 2 achados (cache manual desnecessário, magic number). |
| `review-solid-clean-code` | Achados já cobertos acima sob ótica DRY/SRP/YAGNI. |
| `performance-anti-patterns` | 2 achados (subscription de áudio sem cancelamento explícito, busca linear O(n) em loop). |
| `refactoring-decision-matrix` | Priorizou: duplicação de fonte/cor = Alto (regra: 6+ lugares = Alto/Crítico). |
| `i18n-l10n-patterns` | 1 achado grande (zero infra l10n) + 1 achado específico (data formatada na mão). |

---

## Severidade Alta

| # | Arquivo:linha | Categoria | Problema |
|---|---|---|---|
| 1 | `data/providers/settings_provider.dart:84-96` | Privacidade/LGPD | `UsageDataNotifier` inicia com `enabled = true`; Analytics/Crashlytics coletam antes do usuário ver Ajustes. |
| 2 | Todo `lib/` (ex. `main.dart`, `home_screen.dart:329-340`, `notification_service.dart:69-70`) | i18n | Zero infra de localização: sem `flutter_localizations`/`intl`/`.arb`/`AppLocalizations`. Todo texto é string literal pt. |
| 3 | `core/theme/app_theme.dart:169-235` vs. 20 arquivos | Code smell/DRY | `AppTheme` define `TextTheme` completo; 126 chamadas `GoogleFonts.xxx(...)` espalhadas ignoram e reescrevem tamanho/peso na mão. |
| 4 | `core/extensions/build_context_extensions.dart:4-13` vs. 10+ arquivos | Code smell/DRY | `context.colorBg/colorText/colorAccent` prontos existem; 10+ arquivos reimplementam `isDark ? nightX : dayX` na mão. |

**Por quê e como corrigir:**

- **#1 LGPD default-on:** dado sensível (crença/estado emocional) exige consentimento explícito *antes* de coletar, não interruptor ligado de fábrica. App em teste fechado — momento certo de resolver antes do lançamento público, evita problema jurídico depois. **Fix:** padrão desligado até confirmação no onboarding, ou tela de consentimento clara.
- **#2 sem l10n:** projeto documenta pt/en como padrão, mas hoje ativar inglês = reescrever 44 arquivos na mão, risco alto de esquecer string. **Fix:** `flutter_localizations` + `intl`, strings em `.arb` (`app_pt.arb`/`app_en.arb`), `AppLocalizations.of(context)`.
- **#3 fontes duplicadas:** app já tem "manual de estilo" (`AppTheme`) que quase ninguém usa. Mudar tamanho do número do Salmo ou peso do título = caçar e editar em 20 arquivos, risco de esquecer um e ficar "torto". **Fix:** consolidar estilos repetidos como getters nomeados em `AppTheme`/`TextTheme`, trocar `GoogleFonts.xxx(...)` por `Theme.of(context).textTheme.xxx`.
- **#4 cor clara/escura duplicada:** mesmo problema do #3 pra cores. Atalho pronto existe (`context.colorBg`...), maioria ignora. Mudar tom no design system = caçar espalhado. **Fix:** trocar ternários repetidos pelos getters da extension.

---

## Severidade Média

| # | Arquivo:linha | Categoria | Problema |
|---|---|---|---|
| 5 | `ajustes_screen.dart:31-49`, `detalhe_colecao_screen.dart:160-181`, `compositor_screen.dart:473-486`, `leitura_salmo_screen.dart:524-556`, `respirar_screen.dart:45-67` | Duplicate code | "Botão circular com borda/seta" implementado do zero em 5+ lugares. |
| 6 | `ajustes_screen.dart` (750 linhas), `leitura_salmo_screen.dart` (671), `onboarding_screen.dart` (643), `home_screen.dart` (587), `compositor_screen.dart` (580) | SOLID (SRP)/Large Class | 5 telas passam de 580 linhas. `ajustes_screen.dart` mistura tema, notificações, Pix, sobre, sugestões, privacidade num arquivo só. |
| 7 | `home_screen.dart:80-341` | Long Method | `_HomeContent.build()` é um método só de ~260 linhas montando a tela inteira. |
| 8 | `collection_card.dart:27-34`, `onboarding_provider.dart:32-41`, `tema_chip.dart:10-69` | SOLID (OCP)/Primitive obsession | Lista das 8 coleções hardcoded em 3 lugares sem checagem cruzada. Coleção nova esquecida em um lugar falha silenciosamente. |
| 9 | `home_screen.dart:328-340` | i18n/code smell | Data formatada na mão (arrays de dias/meses pt), comentário diz que evita `intl` de propósito. |
| 10 | `data/providers/audio_provider.dart:64-74` | Performance/memory | `positionStream`/`playingStream` sem `StreamSubscription` guardada pra cancelamento explícito. |
| 11 | `features/favoritos/favoritos_screen.dart:22-56` | Anti-pattern (otimização prematura) | Cache manual pra evitar reordenar até 150 favoritos — tela irmã reconhece no comentário que isso é instantâneo sem cache. |
| 12 | `review_service.dart:8-9`, `favoritos_provider.dart:6` vs. `app_constants.dart` | Magic strings | Catálogo central de chaves `SharedPreferences` existe (`AppConstants`), essas 2 ficam soltas fora dele. |

**Por quê e como corrigir (resumido):**

- **#5:** botão copiado/colado em telas diferentes — mudar estilo (acessibilidade, área de toque) exige lembrar de mudar em cada uma. **Fix:** extrair `CircleIconButton` compartilhado.
- **#6:** arquivo de 750 linhas é caro de ler, arriscado de editar sem esbarrar numa seção sem querer. **Fix:** quebrar `ajustes_screen.dart` em widgets por seção, arquivos próprios.
- **#7:** método gigante difícil de entender/ajustar sem reler tudo. **Fix:** extrair sub-blocos como widgets nomeados (já feito com `_RespirarCard`).
- **#8:** 9ª coleção esquecida num dos 3 lugares = card com cor/label errados sem aviso. **Fix:** centralizar coleção→cor/label/emoji num mapa único.
- **#9:** funciona só porque app é só português hoje; reinventa o que Flutter já resolve, vira mais um lugar a reescrever se virar bilíngue. **Fix:** `DateFormat` do `intl` junto com #2.
- **#10:** costuma funcionar, mas padrão frágil — evento de posição na hora que a tela fecha pode tentar atualizar estado que já não existe. **Fix:** guardar subscriptions, cancelar explicitamente antes de `dispose()`.
- **#11:** complexidade adicionada (cache com controle manual) pra resolver problema que não existe na prática. Aumenta risco de quebra futura sem ajudar em nada. **Fix:** remover cache, reordenar direto a cada build.
- **#12:** não quebra nada, dificulta auditar tudo que o app grava no aparelho num lugar só. **Fix:** mover as 2 chaves pra `AppConstants`.

---

## Severidade Baixa

| # | Arquivo:linha | Categoria | Problema |
|---|---|---|---|
| 13 | `notification_service.dart:65` | Magic number | Total de 150 salmos hardcoded (`% 150`) em vez de derivado da lista real. |
| 14 | `shared/entitlements/entitlements.dart` (21 linhas), `shared/widgets/placeholder_screen.dart` (43 linhas) | Dead code | Nenhum é referenciado em nenhum outro arquivo (confirmado). |
| 15 | `core/firebase_options.dart:55-61` | Segurança (informativo) | API key Firebase hardcoded — arquivo gerado pelo FlutterFire CLI, é público por design. |
| 16 | `salmos_repository.dart:29-36`, usado em loop em `detalhe_colecao_screen.dart:58-61` | Performance | Busca de Salmo por número é O(n) em vez de O(1), chamada dentro de loop. |

**Por quê e como corrigir (resumido):**

- **#13:** se conteúdo mudar, notificação diária pode sugerir Salmo inexistente. **Fix:** calcular total a partir da lista real.
- **#14:** dois arquivos "preparados pro futuro" (paywall, telas não feitas) só ocupam espaço mental. **Fix:** remover agora (git guarda histórico), recriar quando a feature for real.
- **#15:** não é como senha, protege via regras do Console, não escondendo a chave. **Fix:** nenhuma mudança de código — confirmar no Google Cloud Console que API key Android está restrita ao package name/SHA-1, considerar Firebase App Check.
- **#16:** com 150 salmos é imperceptível pro usuário, piora proporcionalmente se catálogo crescer. **Fix:** indexar por número (`Map<int, Salmo>`) — repositório já mantém cache da lista.

---

## Pontos bons (não pedido, mas relevante)

- `analytics_service.dart` já toma cuidado deliberado de nunca logar título da coleção ("Ansiedade", "Luto"), só o `id` — evita vincular estado emocional/religioso ao device (comentário cita LGPD Art. 11 explicitamente). O problema real é o *default* de coleta (#1), não a telemetria em si, que já foi desenhada com cuidado.
- Parse do JSON (`salmos_repository.dart`) é resiliente item a item — registro quebrado não derruba o app inteiro.
- Tratamento de erro e estados vazios/loading é consistente em praticamente todas as telas.
- Nenhum achado Crítico: sem crash conhecido, sem perda de dado, sem falha de segurança explorável. Bom sinal pra app pequeno, offline, sem login.

---

## Validação — 2ª auditoria independente (2026-08-07)

Depois de aplicar os 16 achados, rodei uma segunda auditoria do zero (mesmas skills, sem olhar pro relatório de fixes) pra conferir se seguraram. `flutter analyze` 0 issues, `flutter test` 16/16, `flutter build apk --debug` compila.

**2 lacunas achadas e fechadas** (commit `57fc7f7`):
- #16 tinha sido resolvido só dentro de `salmos_repository.dart` — o loop em `detalhe_colecao_screen.dart:60-63` que o achado original também citava continuava com busca linear. Corrigido com Map local.
- Limpeza em lote do #4 deixou parâmetro `isDark` morto (passado mas nunca lido) em 4 classes de 3 arquivos (`compositor_screen.dart` ×2, `detalhe_colecao_screen.dart`, `onboarding_screen.dart`). Removido.

**Achados novos, não corrigidos (baixa prioridade, cosmético/organização — sem prazo real):**
- `_BookmarkPainter` duplicado byte-a-byte em `splash_screen.dart` e `onboarding_screen.dart` — mover pra `shared/widgets/` se for mexer no ícone de marcador algum dia.
- Ternário `context.canPop() ? context.pop() : context.go(...)` repetido em 5 lugares — daria pra virar `context.popOrGo(fallback)`.
- `_CompositorBody` com 10 parâmetros obrigatórios — sintoma de estado que podia estar agrupado, não é bug.
- `error_state_view.dart` usa `.withValues(alpha:)` (API nova) enquanto o resto do app usa `.withAlpha()` (API antiga) — funciona igual, só inconsistente.
- `onboarding_screen.dart` `_Page2`: card no modo claro usa `Colors.white` puro em vez de `context.colorSurface` (`dayPlus`, branco levemente azulado) — pode ser intencional, mas é a única superfície do app fora do design system central.
