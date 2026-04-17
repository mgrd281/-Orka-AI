/// Orka AI — API Service
///
/// Central HTTP client with auth token management.

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _baseUrl = 'http://localhost:8000/api/v1';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request
            final token = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$_baseUrl/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      await _storage.write(key: 'access_token', value: response.data['access_token']);
      await _storage.write(key: 'refresh_token', value: response.data['refresh_token']);
      return true;
    } catch (e) {
      return false;
    }
  }

  // === Auth ===

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
    String language = 'de',
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'language': language,
    });
    await _storeTokens(response.data);
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _storeTokens(response.data);
    return response.data;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<void> _storeTokens(Map<String, dynamic> data) async {
    await _storage.write(key: 'access_token', value: data['access_token']);
    await _storage.write(key: 'refresh_token', value: data['refresh_token']);
  }

  Future<bool> get isAuthenticated async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  // === Conversations ===

  Future<Map<String, dynamic>> createConversation({String mode = 'smart'}) async {
    final response = await _dio.post('/chat/conversations', data: {'mode': mode});
    return response.data;
  }

  Future<List<dynamic>> listConversations({int skip = 0, int limit = 20}) async {
    final response = await _dio.get('/chat/conversations', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getConversation(String id) async {
    final response = await _dio.get('/chat/conversations/$id');
    return response.data;
  }

  Future<void> deleteConversation(String id) async {
    await _dio.delete('/chat/conversations/$id');
  }

  Future<void> updateConversation(String id, {String? title, bool? isArchived}) async {
    await _dio.patch('/chat/conversations/$id', data: {
      if (title != null) 'title': title,
      if (isArchived != null) 'is_archived': isArchived,
    });
  }

  // === Messages (Streaming) ===

  Stream<Map<String, dynamic>> sendMessageStream({
    required String conversationId,
    required String content,
    String mode = 'smart',
  }) async* {
    final response = await _dio.post(
      '/chat/conversations/$conversationId/messages',
      data: {'content': content, 'mode': mode},
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream as Stream<List<int>>;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);
      final lines = buffer.split('\n');
      buffer = lines.last; // Keep incomplete line in buffer

      for (final line in lines.take(lines.length - 1)) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;
          try {
            yield json.decode(data);
          } catch (_) {}
        }
      }
    }
  }

  // === User ===

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/user/profile');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/user/profile', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getUsage() async {
    final response = await _dio.get('/user/usage');
    return response.data;
  }

  // === Subscriptions ===

  Future<List<dynamic>> getPlans({String lang = 'de'}) async {
    final response = await _dio.get('/subscriptions/plans', queryParameters: {'lang': lang});
    return response.data;
  }

  Future<Map<String, dynamic>> createCheckout(String planId) async {
    final response = await _dio.post('/subscriptions/checkout', data: {'plan_id': planId});
    return response.data;
  }
}
