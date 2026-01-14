import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kAccess = 'bb_access';
  static const _kRefresh = 'bb_refresh';
  final _s = const FlutterSecureStorage();

  Future<void> save({required String access, required String refresh}) async {
    await _s.write(key: _kAccess, value: access);
    await _s.write(key: _kRefresh, value: refresh);
  }

  Future<String?> get access async => _s.read(key: _kAccess);
  Future<String?> get refresh async => _s.read(key: _kRefresh);

  Future<void> clear() async {
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
  }
}
