// lib/services/voice_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../controllers/settings_controller.dart';
import '../controllers/panic_button_controller.dart';

class VoiceService {
  final _stt = SpeechToText();
  bool _listening = false;
  Timer? _retryTimer;

  Future<void> start() async {
    final settingsCtrl = Get.find<SettingsController>();
    final panicCtrl    = Get.find<PanicButtonController>();

    debugPrint('🎤 VoiceService: initialize()');
    bool ok = await _stt.initialize(
      onStatus: (status) => _onStatus(status, settingsCtrl, panicCtrl),
      onError:  (err)    => _onError(err, settingsCtrl, panicCtrl),
    );
    debugPrint('🎤 STT initialized: $ok');
    if (ok) _listen(panicCtrl, settingsCtrl);
  }

  void _onStatus(String status, SettingsController settings, PanicButtonController panic) {
    debugPrint('🎤 STT status: $status');
    if (status == 'done' && settings.prefs.value.useVoice) {
      _listening = false;
      _scheduleRetry(panic, settings);
    }
  }

  void _onError(SpeechRecognitionError err, SettingsController settings, PanicButtonController panic) {
    debugPrint('🎤 STT error: $err');
    _listening = false;
    // Si el motor está ocupado o no hay match, reintenta tras 2s
    if (settings.prefs.value.useVoice) {
      _scheduleRetry(panic, settings);
    }
  }

  void _listen(PanicButtonController panic, SettingsController settings) {
    if (_listening || !settings.prefs.value.useVoice) return;
    _listening = true;

    _stt.listen(
      onResult: (res) {
        final rec = res.recognizedWords.toLowerCase();
        final trg = settings.prefs.value.alertText.toLowerCase();
        debugPrint('🎤 result: "$rec" vs "$trg"');

        if (rec.contains(trg)) {
          debugPrint('🎤 trigger detected, firing alerts');
          final triggers = settings.prefs.value.buttonTriggers;
          for (var btn in panic.buttons) {
            if (triggers[btn.id]?.contains('voice') == true) {
              panic.triggerAlert(btn);
            }
          }
          // Una vez detectado, desactiva el switch y detén el servicio
          settings.toggleVoice(false);
          stop();
        }
      },
      localeId: 'es_ES',
      listenMode: ListenMode.dictation,
      partialResults: true,
      listenFor: const Duration(seconds: 8),
      pauseFor:  const Duration(seconds: 4),
    );
  }

  void _scheduleRetry(PanicButtonController panic, SettingsController settings) {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 2), () {
      if (settings.prefs.value.useVoice) {
        debugPrint('🎤 Retry listening...');
        _listen(panic, settings);
      }
    });
  }

  void stop() {
    debugPrint('🎤 VoiceService: stop()');
    _retryTimer?.cancel();
    _stt.stop();
    _listening = false;
  }
}
