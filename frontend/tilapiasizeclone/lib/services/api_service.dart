import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Error thrown when FastAPI cannot be reached.
class ServerUnavailableException implements Exception {
  const ServerUnavailableException();
}

// Error returned by FastAPI, such as an email already registered.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _tokenStorageKey = 'tilapiasize_access_token';
  static const _accountStorageKey = 'tilapiasize_account';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Keep a memory copy for requests and an encrypted copy across app launches.
  static String? _accessToken;
  static bool get hasSession => _accessToken != null;

  static Future<void> clearSession() async {
    _accessToken = null;
    try {
      await _secureStorage.delete(key: _tokenStorageKey);
      await _secureStorage.delete(key: _accountStorageKey);
    } catch (_) {
      // The in-memory session is still cleared if secure storage is unavailable.
    }
  }

  static Future<Map<String, dynamic>?> restoreSession() async {
    try {
      final token = await _secureStorage.read(key: _tokenStorageKey);
      final savedAccount = await _secureStorage.read(key: _accountStorageKey);
      if (token == null || savedAccount == null) {
        await clearSession();
        return null;
      }

      final expiresAt = _tokenExpiration(token);
      if (expiresAt == null || !expiresAt.isAfter(DateTime.now().toUtc())) {
        await clearSession();
        return null;
      }

      final decodedAccount = jsonDecode(savedAccount);
      if (decodedAccount is! Map) {
        await clearSession();
        return null;
      }

      _accessToken = token;
      return Map<String, dynamic>.from(decodedAccount);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  static DateTime? _tokenExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map || payload['exp'] is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        (payload['exp'] as num).toInt() * 1000,
        isUtc: true,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getProfile() =>
      _profileRequest('GET', '/profile');

  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String farmName,
    required String farmLocation,
  }) => _profileRequest('PUT', '/profile', {
    'full_name': fullName.trim(),
    'farm_name': farmName.trim(),
    'farm_location': farmLocation.trim(),
  });

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _profileRequest('POST', '/profile/password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  static Future<Map<String, dynamic>> _profileRequest(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final token = _accessToken;
    if (token == null) throw const ApiException(401, 'Please log in again.');
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);
    final client = http.Client();
    late http.Response response;
    try {
      response = await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const ServerUnavailableException();
    } finally {
      client.close();
    }
    final data = _readResponse(response);
    if (response.statusCode == 401) await clearSession();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        _errorMessage(
          data,
          'Unable to save. Check your details and try again.',
        ),
      );
    }
    return data;
  }

  // Flutter Web and desktop development use localhost.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (Platform.isAndroid) {
      // This computer's current Wi-Fi address. Override it with
      // --dart-define=API_BASE_URL=http://<computer-ip>:8000 if it changes.
      return 'http://192.168.1.11:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  // Register a farmer using the FastAPI backend.
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'full_name': fullName,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ServerUnavailableException();
    }

    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(response.statusCode, 'Unexpected server response.');
    }

    if (response.statusCode == 201) {
      return data;
    }

    // Display friendly errors returned by FastAPI.
    final detail = data['detail'];

    throw ApiException(
      response.statusCode,
      detail is String ? detail : 'Registration failed.',
    );
  }

  // Check whether FastAPI is responding.
  static Future<bool> isServerAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ServerUnavailableException();
    }

    final Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(response.statusCode, 'Unexpected server response.');
    }

    if (response.statusCode == 200) {
      final token = data['access_token'];
      if (token is! String || token.isEmpty) {
        throw const ApiException(
          500,
          'The server did not return a login session.',
        );
      }
      _accessToken = token;
      final user = data['user'];
      if (user is Map) {
        try {
          await _secureStorage.write(key: _tokenStorageKey, value: token);
          await _secureStorage.write(
            key: _accountStorageKey,
            value: jsonEncode(Map<String, dynamic>.from(user)),
          );
        } catch (_) {
          // Preserve the active session even if device storage is unavailable.
          await clearSession();
          _accessToken = token;
        }
      }
      return data;
    }

    throw ApiException(
      response.statusCode,
      data['detail'] is String
          ? data['detail'] as String
          : 'Login failed. Please try again.',
    );
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp_code': otpCode}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ServerUnavailableException();
    }

    final data = _readResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw ApiException(
      response.statusCode,
      _errorMessage(data, 'Verification failed.'),
    );
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/resend-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ServerUnavailableException();
    }

    final data = _readResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw ApiException(
      response.statusCode,
      _errorMessage(data, 'Unable to resend OTP.'),
    );
  }

  // Read JSON responses from FastAPI.
  static Map<String, dynamic> _readResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Handle responses that are not valid JSON.
    }

    throw ApiException(response.statusCode, 'Unexpected server response.');
  }

  // Get readable error messages from FastAPI.
  static String _errorMessage(Map<String, dynamic> data, String fallback) {
    final detail = data['detail'];

    if (detail is String) {
      return detail;
    }

    return fallback;
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ServerUnavailableException();
    }

    final data = _readResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw ApiException(
      response.statusCode,
      _errorMessage(data, 'Unable to request a password reset.'),
    );
  }

  static Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otpCode,
  }) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-reset-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'otp_code': otpCode}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ServerUnavailableException();
    }

    final data = _readResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw ApiException(
      response.statusCode,
      _errorMessage(data, 'Invalid verification code.'),
    );
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'reset_token': resetToken,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      throw const ServerUnavailableException();
    }

    final data = _readResponse(response);

    if (response.statusCode == 200) {
      return data;
    }

    throw ApiException(
      response.statusCode,
      _errorMessage(data, 'Unable to reset password.'),
    );
  }
}
