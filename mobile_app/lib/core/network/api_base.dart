import 'dart:io';
import 'package:flutter/foundation.dart';

const String _lanPc = 'http://192.168.1.112:4001'; // PC đang chạy BE
const String _emu = 'http://10.0.2.2:3000';       // Android Emulator AVD - Only change here if use android studio virtual machine

String apiBase() {
  // Ưu tiên biến môi trường
  const fromEnv = String.fromEnvironment('API_BASE', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) return _lanPc;

  if (Platform.isAndroid) {
    // Nếu chạy trên EMULATOR thì dùng 10.0.2.2; còn lại (thiết bị thật) dùng IP LAN của PC
    const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
    return isEmulator ? _emu : _lanPc;
  }

  // iOS simulator / macOS / Windows → gọi thẳng IP LAN của PC
  return _lanPc;
}
