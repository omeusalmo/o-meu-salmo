# Refactoring & Performance Plan

> **For Claude:** Use flutter-craft:flutter-executing to implement task-by-task.

**Goal:** Eliminate 5 recurring code smells that cause unnecessary rebuilds, duplicated boilerplate, and iOS incompatibility before the app expands to Apple.

**Architecture:** Clean Architecture, Riverpod 2.5.1, GoRouter 13.2.5, Dart 3

**New dependencies:** none

---

## Summary of findings

| # | Severity | File(s) | Issue |
|---|---|---|---|
| 1 | 🔴 CODE SMELL | 17 files | `Theme.of(context).brightness` repeated every build — 3-line boilerplate in every widget |
| 2 | 🟡 PERF | `favoritos_screen.dart:63–71` | `favoritos.sort()` runs inside `build()` — O(n log n) per rebuild including unrelated provider changes |
| 3 | 🟡 MAINT | `audio_player_bar.dart` | `build()` is 194 lines, single method doing layout + state + animation logic |
| 4 | 🟡 PERF | `favoritos_provider.dart` | `SharedPreferences.getInstance()` called twice per `toggle()` (once in `FavoritesNotifier`, once in `FavTimestampsNotifier`) + on every `build()` |
| 5 | 🔴 iOS BLOCKER | `notification_service.dart` | Android-only init — will crash on iOS when platform is added |

---

## Task 1 — `context.isDark` BuildContext extension

**Layer:** Core / Theme
**Effort:** 30 min

### Problem

Every widget repeats:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final bg     = isDark ? AppColors.nightBase : AppColors.dayBase;
final accent = isDark ? AppColors.cobalt400 : AppColors.cobalt500;
// ... 4–6 more lines
```

17 files affected. Zero semantic value — pure boilerplate. Also calls `Theme.of(context)` once per variable, potentially multiple times per build.

### Fix

**Files:**
- Create: `lib/core/extensions/build_context_extensions.dart`
- Modify: all 17 widgets (replace `Theme.of(context).brightness == Brightness.dark` → `context.isDark`)

**Implementation:**

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

extension BuildContextX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Convenience accessors — single Theme.of() call per getter
  Color get colorBg     => isDark ? AppColors.nightBase  : AppColors.dayBase;
  Color get colorSurface=> isDark ? AppColors.nightPlus  : AppColors.dayPlus;
  Color get colorBorder => isDark ? AppColors.nightLine  : AppColors.dayLine;
  Color get colorTitle  => isDark ? AppColors.nightCream : AppColors.dayTitle;
  Color get colorText   => isDark ? AppColors.nightText  : AppColors.dayText;
  Color get colorMuted  => isDark ? AppColors.nightText  : AppColors.dayText;
  Color get colorAccent => isDark ? AppColors.cobalt400  : AppColors.cobalt500;
}
```

**Usage after:**
```dart
// Before (every widget)
final isDark   = Theme.of(context).brightness == Brightness.dark;
final bg       = isDark ? AppColors.nightBase  : AppColors.dayBase;
final titleClr = isDark ? AppColors.nightCream : AppColors.dayTitle;
final accent   = isDark ? AppColors.cobalt400  : AppColors.cobalt500;

// After
final bg       = context.colorBg;
final titleClr = context.colorTitle;
final accent   = context.colorAccent;
```

**Files to update:** (all 17 — replace line-by-line, `isDark` bool can stay where needed for conditional logic)

```
lib/features/home/home_screen.dart
lib/features/ajustes/ajustes_screen.dart
lib/features/compositor/compositor_screen.dart
lib/features/favoritos/favoritos_screen.dart
lib/features/colecoes/colecoes_screen.dart
lib/features/colecoes/detalhe_colecao_screen.dart
lib/features/salmos/leitura_salmo_screen.dart
lib/features/salmos/todos_salmos_screen.dart
lib/features/onboarding/onboarding_screen.dart
lib/shared/widgets/audio_player_bar.dart
lib/shared/widgets/verse_line.dart
lib/shared/widgets/eyebrow_label.dart
lib/shared/widgets/main_shell.dart
lib/shared/widgets/collection_card.dart
lib/shared/widgets/placeholder_screen.dart
lib/shared/widgets/psalm_card.dart
```

**Verification:**
```bash
cd app && flutter analyze
# Expected: 0 issues
```

**Commit:**
```bash
git add lib/core/extensions/ lib/features/ lib/shared/
git commit -m "refactor: add context.isDark extension, remove Theme.of boilerplate from 17 files"
```

---

## Task 2 — FavoritosScreen: move sort out of build()

**Layer:** Presentation
**Effort:** 20 min

### Problem

`favoritos_screen.dart:63–71`:
```dart
// Runs every build() — triggered by favoritosProvider, salmosProvider, OR favTimestampsProvider changes
final favoritos = todos.where((s) => numeros.contains(s.numero)).toList();
if (_sortOrder == _FavSortOrder.byRecent) {
  favoritos.sort((a, b) { ... }); // allocates + sorts every rebuild
} else {
  favoritos.sort((a, b) => a.numero.compareTo(b.numero));
}
```

`favTimestampsProvider` changes on every add/remove — triggers a rebuild and re-sort even when the list didn't change.

### Fix

Cache in state, rebuild only when inputs change.

**File:** `lib/features/favoritos/favoritos_screen.dart`

Replace the sort block in `build()` with a `_buildSortedList()` that is called only when `_sortOrder`, `numeros`, `todos`, or `timestamps` change:

```dart
// Inside _FavoritosScreenState
List<Salmo> _lastFavoritos = [];
Set<int>    _lastNumeros   = {};
Map<int,int>_lastTimestamps= {};
_FavSortOrder _lastSortOrder = _FavSortOrder.byNumber;

List<Salmo> _sortedFavoritos({
  required Set<int>     numeros,
  required List<Salmo>  todos,
  required Map<int,int> timestamps,
}) {
  if (numeros == _lastNumeros &&
      todos == _lastFavoritos &&
      timestamps == _lastTimestamps &&
      _sortOrder == _lastSortOrder) {
    return _lastFavoritos;
  }
  final list = todos.where((s) => numeros.contains(s.numero)).toList();
  if (_sortOrder == _FavSortOrder.byRecent) {
    list.sort((a, b) {
      final ta = timestamps[a.numero] ?? 0;
      final tb = timestamps[b.numero] ?? 0;
      return tb.compareTo(ta);
    });
  } else {
    list.sort((a, b) => a.numero.compareTo(b.numero));
  }
  _lastNumeros    = numeros;
  _lastTimestamps = timestamps;
  _lastSortOrder  = _sortOrder;
  _lastFavoritos  = list;
  return list;
}
```

Then in `build()`, replace the current sort block:
```dart
// Before
final favoritos = todos.where(...).toList();
favoritos.sort(...);

// After
final favoritos = _sortedFavoritos(
  numeros: numeros, todos: todos, timestamps: timestamps,
);
```

**Note:** Simpler alternative if codebase grows: derive a `sortedFavoritosFamily` Riverpod provider. For current scale (≤150 psalms) the stateful cache above is sufficient and adds no complexity.

**Verification:**
```bash
cd app && flutter analyze && flutter test
```

**Commit:**
```bash
git add lib/features/favoritos/favoritos_screen.dart
git commit -m "perf(favoritos): cache sorted list in state, avoid re-sort on unrelated rebuilds"
```

---

## Task 3 — SharedPreferences: single instance via provider

**Layer:** Data
**Effort:** 20 min

### Problem

`favoritos_provider.dart` calls `SharedPreferences.getInstance()` inside:
1. `FavoritesNotifier.build()` — async init
2. `FavoritesNotifier.toggle()` — on every toggle
3. `FavTimestampsNotifier.build()` — async init
4. `FavTimestampsNotifier._save()` — on every add/remove

`getInstance()` is a singleton under the hood but each call is still an async lookup + potential microtask. The pattern also makes testing harder.

### Fix

**File:** `lib/data/providers/favoritos_provider.dart`

Add a shared prefs provider at the top:
```dart
final _sharedPrefsProvider = FutureProvider<SharedPreferences>(
  (_) => SharedPreferences.getInstance(),
);
```

Update both notifiers to read from it:
```dart
class FavoritesNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final prefs = await ref.watch(_sharedPrefsProvider.future);
    final list  = prefs.getStringList(AppConstants.prefFavoritosKey) ?? [];
    return list.map(int.parse).toSet();
  }

  Future<void> toggle(int numero) async {
    final current = await future;
    final updated = Set<int>.from(current);
    final adding  = !current.contains(numero);
    adding ? updated.add(numero) : updated.remove(numero);
    if (adding) ref.read(favTimestampsProvider.notifier).add(numero);
    else        ref.read(favTimestampsProvider.notifier).remove(numero);
    state = AsyncValue.data(updated);
    AnalyticsService.instance.logPsalmFavorited(numero, added: adding);
    final prefs = await ref.read(_sharedPrefsProvider.future); // cached, no new I/O
    await prefs.setStringList(
      AppConstants.prefFavoritosKey,
      updated.map((n) => n.toString()).toList(),
    );
  }
  // ...
}
```

Same pattern for `FavTimestampsNotifier`.

**Verification:**
```bash
cd app && flutter analyze && flutter test
```

**Commit:**
```bash
git add lib/data/providers/favoritos_provider.dart
git commit -m "refactor(providers): single SharedPreferences instance via FutureProvider"
```

---

## Task 4 — AudioPlayerBar: extract sub-widgets

**Layer:** Presentation
**Effort:** 30 min

### Problem

`audio_player_bar.dart` has a 194-line `build()` method in `_AudioPlayerBarState`. Three distinct UI concerns in one method:
- Play/pause button (`_PlayButton` already extracted as `_PlayerIcon` but the button shell is not)
- Time display (position + duration labels)
- Progress track + seek + animated fill

### Fix

Extract two sub-widgets into the same file (private, no new files needed).

**File:** `lib/shared/widgets/audio_player_bar.dart`

```dart
// ─── New sub-widget: _PlayPauseButton ────────────────────────────────────────

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final bool available;
  final Color color;
  final VoidCallback? onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.available,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isPlaying ? 'Pausar áudio' : 'Ouvir o Salmo',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: available
                ? [BoxShadow(color: AppColors.cobalt600.withAlpha(77), blurRadius: 30, offset: const Offset(0, 12))]
                : null,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.nightCream),
                  )
                : _PlayerIcon(isPlaying: isPlaying),
          ),
        ),
      ),
    );
  }
}

// ─── New sub-widget: _ProgressTrack ──────────────────────────────────────────

class _ProgressTrack extends StatelessWidget {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final GestureTapUpCallback? onSeek;

  const _ProgressTrack({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onTapUp: onSeek != null
            ? (d) => onSeek!(TapUpDetails(
                  kind: d.kind,
                  localPosition: Offset(
                    (d.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0) * constraints.maxWidth,
                    d.localPosition.dy,
                  ),
                  globalPosition: d.globalPosition,
                ))
            : null,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(height: 3, decoration: BoxDecoration(color: trackColor, borderRadius: BorderRadius.circular(2))),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(height: 3, decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(2))),
                  ),
                  Positioned(
                    left: 0, right: 0,
                    child: FractionallySizedBox(
                      widthFactor: value,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(width: 10, height: 10, decoration: BoxDecoration(color: fillColor, shape: BoxShape.circle)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

`_AudioPlayerBarState.build()` shrinks to ~50 lines (colors + state wiring + `Row` layout).

**Verification:**
```bash
cd app && flutter analyze
```

**Commit:**
```bash
git add lib/shared/widgets/audio_player_bar.dart
git commit -m "refactor(audio-player): extract _PlayPauseButton and _ProgressTrack sub-widgets"
```

---

## Task 5 — NotificationService: iOS-ready init

**Layer:** Core / Services  
**Effort:** 20 min  
**Priority for iOS launch (not needed before Android Go-Live)**

### Problem

`notification_service.dart:21–24`:
```dart
const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
const initSettings = InitializationSettings(android: androidInit);
await _plugin.initialize(initSettings);
```

- No `DarwinInitializationSettings` → `FlutterLocalNotificationsPlugin.initialize()` returns `false` on iOS
- `requestPermission()` returns `false` on iOS silently
- `AndroidScheduleMode.exactAllowWhileIdle` → needs conditional when iOS support added
- `AndroidNotificationDetails` → crashes on iOS if used without `DarwinNotificationDetails`

### Fix

**File:** `lib/core/notifications/notification_service.dart`

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _dailyPsalmId = 1;
  static const String _channelId   = 'salmo_diario';
  static const String _channelName = 'Salmo diário';

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit     = DarwinInitializationSettings(
      requestAlertPermission: false, // request explicitly via requestPermission()
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return false;
  }

  Future<void> scheduleDailySalmo(int hour, int minute) async {
    await cancelDailySalmo();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    final numero = (_dayOfYear(scheduled) - 1) % 150 + 1;

    await _plugin.zonedSchedule(
      _dailyPsalmId,
      'Seu Salmo de hoje chegou.',
      'Salmo $numero — um momento para você.',
      scheduled,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailySalmo() => _plugin.cancel(_dailyPsalmId);

  int _dayOfYear(DateTime d) => d.difference(DateTime(d.year, 1, 1)).inDays + 1;
}
```

**Additional iOS setup needed in `ios/Runner/Info.plist`** (when iOS target is added):
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

**Verification:**
```bash
cd app && flutter analyze
# No new issues. iOS behavior can only be verified on simulator.
```

**Commit:**
```bash
git add lib/core/notifications/notification_service.dart
git commit -m "feat(notifications): add iOS DarwinInitializationSettings, platform-aware permission request"
```

---

## Execution order

Recommended sequence (each independent, can do in order):

1. **Task 1** (extension) — biggest impact, touches most files, sets foundation
2. **Task 3** (SharedPreferences) — small, low risk, improves testability
3. **Task 2** (FavoritosScreen sort) — remove rebuild smell
4. **Task 4** (AudioPlayerBar split) — maintenance win
5. **Task 5** (iOS notifications) — only when iOS lane starts

## What NOT to do now

- Google Fonts precomputed styles → Google Fonts already caches `TextStyle` objects internally; benefit negligible, cost = large refactor
- Riverpod `select()` for FavoritosScreen → overkill for ≤150 items; Task 2 cache is sufficient
- `go_router` vs Navigator direct API → GoRouter is correct here, no migration needed
- Adaptive CupertinoWidgets → premature for Android-only MVP; add only when iOS UI review is done
