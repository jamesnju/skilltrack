import 'package:flutter/services.dart';

class FocusModeService {
  FocusModeService._();

  static final FocusModeService instance = FocusModeService._();

  static const MethodChannel _channel = MethodChannel(
    'com.example.skill_track/focus_mode',
  );

  Future<bool> get hasDndAccess async {
    return await _channel.invokeMethod<bool>('hasDndAccess') ?? false;
  }

  Future<void> openDndSettings() async {
    await _channel.invokeMethod<void>('openDndSettings');
  }

  Future<bool> enableDnd() async {
    return await _channel.invokeMethod<bool>('enableDnd') ?? false;
  }

  Future<bool> restoreDnd() async {
    return await _channel.invokeMethod<bool>('restoreDnd') ?? false;
  }
}
