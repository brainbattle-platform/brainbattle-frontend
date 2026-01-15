import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_base.dart'; // đúng vị trí: core/network/api_base.dart
import '../services/token_storage.dart'; // đúng vị trí: core/services/token_storage.dart

class UserApi {
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final token = await TokenStorage().access;
    final resp = await http.get(
      Uri.parse('${apiBase()}/v1/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(resp.body);
  }

  Future<Map<String, dynamic>> getFollowers(String userId, {int skip = 0, int take = 20}) async {
    final token = await TokenStorage().access;
    final resp = await http.get(
      Uri.parse('${apiBase()}/v1/users/$userId/followers?skip=$skip&take=$take'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(resp.body);
  }

  Future<Map<String, dynamic>> getFollowing(String userId, {int skip = 0, int take = 20}) async {
    final token = await TokenStorage().access;
    final resp = await http.get(
      Uri.parse('${apiBase()}/v1/users/$userId/following?skip=$skip&take=$take'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return jsonDecode(resp.body);
  }
}
