import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../user/user_context_service.dart';

/// HTTP client wrapper that automatically adds x-user-id header to all requests
/// Includes debug logging for requests/responses in debug builds
class HttpClientWithUser {
  final String baseUrl;
  final UserContextService _userContext = UserContextService.instance;

  HttpClientWithUser({required this.baseUrl});

  /// Get request with user ID header
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
    final allHeaders = await _buildHeaders(headers);
    
    if (kDebugMode) {
      debugPrint('[HTTP GET] $uri');
      debugPrint('[Headers] $allHeaders');
    }
    
    final response = await http.get(uri, headers: allHeaders);
    
    if (kDebugMode) {
      debugPrint('[Response ${response.statusCode}] ${response.request?.url}');
      if (response.body.length < 500) {
        debugPrint('[Body] ${response.body}');
      } else {
        debugPrint('[Body] ${response.body.substring(0, 500)}... (truncated)');
      }
    }
    
    return response;
  }

  /// Post request with user ID header
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = await _buildHeaders(headers);
    final bodyJson = body == null ? null : jsonEncode(body);
    
    if (kDebugMode) {
      debugPrint('[HTTP POST] $uri');
      debugPrint('[Headers] $allHeaders');
      if (bodyJson != null && bodyJson.length < 500) {
        debugPrint('[Body] $bodyJson');
      } else if (bodyJson != null) {
        debugPrint('[Body] ${bodyJson.substring(0, 500)}... (truncated)');
      }
    }
    
    final response = await http.post(
      uri,
      headers: allHeaders,
      body: bodyJson,
    );
    
    if (kDebugMode) {
      debugPrint('[Response ${response.statusCode}] ${response.request?.url}');
      if (response.body.length < 500) {
        debugPrint('[Body] ${response.body}');
      } else {
        debugPrint('[Body] ${response.body.substring(0, 500)}... (truncated)');
      }
    }
    
    return response;
  }

  /// Put request with user ID header
  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = await _buildHeaders(headers);
    final bodyJson = body == null ? null : jsonEncode(body);
    
    if (kDebugMode) {
      debugPrint('[HTTP PUT] $uri');
      debugPrint('[Headers] $allHeaders');
      if (bodyJson != null && bodyJson.length < 500) {
        debugPrint('[Body] $bodyJson');
      } else if (bodyJson != null) {
        debugPrint('[Body] ${bodyJson.substring(0, 500)}... (truncated)');
      }
    }
    
    final response = await http.put(
      uri,
      headers: allHeaders,
      body: bodyJson,
    );
    
    if (kDebugMode) {
      debugPrint('[Response ${response.statusCode}] ${response.request?.url}');
      if (response.body.length < 500) {
        debugPrint('[Body] ${response.body}');
      } else {
        debugPrint('[Body] ${response.body.substring(0, 500)}... (truncated)');
      }
    }
    
    return response;
  }

  /// Delete request with user ID header
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final allHeaders = await _buildHeaders(headers);
    
    if (kDebugMode) {
      debugPrint('[HTTP DELETE] $uri');
      debugPrint('[Headers] $allHeaders');
    }
    
    final response = await http.delete(uri, headers: allHeaders);
    
    if (kDebugMode) {
      debugPrint('[Response ${response.statusCode}] ${response.request?.url}');
      if (response.body.length < 500) {
        debugPrint('[Body] ${response.body}');
      } else {
        debugPrint('[Body] ${response.body.substring(0, 500)}... (truncated)');
      }
    }
    
    return response;
  }

  /// Build headers with x-user-id
  /// Defaults to "user_1" if not set
  Future<Map<String, String>> _buildHeaders(Map<String, String>? existingHeaders) async {
    final userId = await _userContext.getUserId();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-user-id': userId,
      ...?existingHeaders,
    };
    return headers;
  }
}

