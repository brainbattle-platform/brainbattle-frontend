import 'dart:io';
import 'package:flutter/foundation.dart';

const String _lanPc = 'http://10.0.11.123'; // PC IP without port
const String _localhost = 'http://localhost'; // Localhost base
const String _emu = 'http://10.0.2.2';       // Android Emulator AVD

String _baseHost() {
  const fromEnv = String.fromEnvironment('API_HOST', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) return _localhost;

  if (Platform.isAndroid) {
    const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
    return isEmulator ? _emu : _lanPc;
  }

  // iOS simulator / macOS / Windows
  return _localhost;
}

// Messaging service (Community threads, messages, presence)
String apiMessaging() {
  return '${_baseHost()}:4003';
}

// Core service (Clans, users)
String apiCore() {
  return '${_baseHost()}:4002';
}

// Legacy function for other services
String apiBase() {
  return '${_baseHost()}:3001';
}
