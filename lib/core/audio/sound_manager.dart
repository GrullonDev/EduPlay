import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _player.stop();
    }
  }

  Future<void> playAsset(String assetPath) async {
    if (_isMuted) return;
    try {
      // Stop previous sound to avoid overlap chaos in fast games
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing sound $assetPath: $e');
    }
  }

  // Pre-defined game sounds
  Future<void> playCorrect() async => playAsset('audio/correct.mp3');
  Future<void> playWrong() async => playAsset('audio/wrong.mp3');
  Future<void> playWin() async => playAsset('audio/win.mp3');
  Future<void> playPop() async => playAsset('audio/pop.mp3');
  Future<void> playClick() async => playAsset('audio/click.mp3');
}
