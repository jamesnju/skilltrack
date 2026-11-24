import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../models/focus_sound.dart';

class FocusAudioService {
  FocusAudioService._();

  static final FocusAudioService instance = FocusAudioService._();

  final AudioPlayer _player = AudioPlayer();

  FocusSound? _selectedSound;

  AudioPlayer get player => _player;

  FocusSound? get selectedSound => _selectedSound;

  bool get isPlaying => _player.playing;

  Future<void> initialize() async {
    await _player.setVolume(0.65);
  }

  Future<void> play(FocusSound sound) async {
    _selectedSound = sound;

    await _player.stop();

    await _player.setAsset(sound.assetPath);

    await _player.setLoopMode(LoopMode.one);

    unawaited(_player.play());
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    unawaited(_player.play());
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> stop() async {
    await _player.stop();

    _selectedSound = null;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
