import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _baseUrl = 'http://127.0.0.1:8000/api';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  /// Definido em main.dart; chamado automaticamente quando a API retorna 401.
  static void Function()? onUnauthorized;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      _ErrorInterceptor(_storage),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _debugLog(obj.toString()),
      ),
    ]);
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;
}

/// Injeta o Bearer token em toda requisição autenticada.
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'sanctum_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Trata erros HTTP de forma centralizada.
/// Em 401, apaga o token e dispara a navegação para /login via [ApiClient.onUnauthorized].
class _ErrorInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  _ErrorInterceptor(this._storage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 401:
        _storage.delete(key: 'sanctum_token'); // fire-and-forget
        ApiClient.onUnauthorized?.call();
        throw ApiException.unauthorized();
      case 403:
        throw ApiException.forbidden();
      case 422:
        final errors = err.response?.data?['errors'] as Map<String, dynamic>?;
        throw ApiException.validation(errors ?? {});
      case 500:
        throw ApiException.serverError();
      default:
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout) {
          throw ApiException.timeout();
        }
    }
    handler.next(err);
  }
}

// ----------- Exceções personalizadas -----------

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.validationErrors,
  });

  factory ApiException.unauthorized() => const ApiException(
        message: 'Sessão expirada. Faça login novamente.',
        statusCode: 401,
      );

  factory ApiException.forbidden() => const ApiException(
        message: 'Você não tem permissão para esta ação.',
        statusCode: 403,
      );

  factory ApiException.validation(Map<String, dynamic> errors) => ApiException(
        message: 'Dados inválidos.',
        statusCode: 422,
        validationErrors: errors,
      );

  factory ApiException.serverError() => const ApiException(
        message: 'Erro interno no servidor. Tente novamente.',
        statusCode: 500,
      );

  factory ApiException.timeout() => const ApiException(
        message: 'Tempo de conexão esgotado. Verifique sua rede.',
      );

  String? fieldError(String field) {
    final list = validationErrors?[field];
    if (list is List && list.isNotEmpty) return list.first as String;
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

void _debugLog(String msg) {
  assert(() {
    debugPrint('[MaintSys] $msg');
    return true;
  }());
}
