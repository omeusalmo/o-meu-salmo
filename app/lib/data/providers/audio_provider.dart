import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

/// Estado imutável do player.
class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final bool hasError;
  final bool isAvailable; // false quando salmo.audio está vazio ou arquivo ausente
  final Duration position;
  final Duration duration;

  const AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.hasError = false,
    this.isAvailable = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    bool? hasError,
    bool? isAvailable,
    Duration? position,
    Duration? duration,
  }) =>
      AudioState(
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        isAvailable: isAvailable ?? this.isAvailable,
        position: position ?? this.position,
        duration: duration ?? this.duration,
      );
}

class AudioPlayerNotifier extends Notifier<AudioState> {
  late final AudioPlayer _player;
  String? _currentPath;

  @override
  AudioState build() {
    _player = AudioPlayer();

    // Sincroniza posição em tempo real
    _player.positionStream.listen((pos) {
      if (state.isAvailable) {
        state = state.copyWith(position: pos);
      }
    });

    // Sincroniza estado playing/paused
    _player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    // Limpa player quando o provider é descartado (navegação sai da tela)
    ref.onDispose(() => _player.dispose());

    return const AudioState();
  }

  /// Carrega o áudio de um salmo. Chame ao abrir a tela de leitura.
  /// [audioPath] é o valor de Salmo.audio (ex.: "audios/salmo_023.mp3").
  /// Se vazio, o player fica desabilitado silenciosamente.
  Future<void> load(String audioPath) async {
    if (audioPath == _currentPath) return; // já carregado
    _currentPath = audioPath;

    if (audioPath.isEmpty) {
      state = const AudioState(isAvailable: false);
      return;
    }

    state = const AudioState(isLoading: true);
    try {
      final dur = await _player.setAsset('assets/$audioPath');
      state = AudioState(
        isAvailable: true,
        duration: dur ?? Duration.zero,
      );
    } catch (_) {
      // Arquivo ausente no bundle — degradação silenciosa até os MP3 chegarem
      state = const AudioState(isAvailable: false);
      _currentPath = null;
    }
  }

  Future<void> playPause() async {
    if (!state.isAvailable) return;
    if (state.isPlaying) {
      await _player.pause();
    } else {
      // Se chegou ao fim, reinicia
      if (state.position >= state.duration && state.duration > Duration.zero) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    if (!state.isAvailable) return;
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
    _currentPath = null;
    state = const AudioState();
  }
}

final audioPlayerProvider =
    NotifierProvider<AudioPlayerNotifier, AudioState>(AudioPlayerNotifier.new);
