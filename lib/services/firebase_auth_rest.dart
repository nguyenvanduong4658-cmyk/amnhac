import 'dart:convert';
import 'package:http/http.dart' as http;

/// Helper class that calls Firebase Auth REST API directly.
/// This bypasses the firebase_auth SDK which can throw
/// [firebase_auth/unknown-error] on Windows desktop.
class FirebaseAuthRest {
  // Web API key from firebase_options.dart
  static const String _apiKey = 'AIzaSyANhuk01DCYaHy4dZjQYSttujO_F_ZaJzI';

  /// Sign up a new user.  Returns a map with `localId` (uid), `email`,
  /// `idToken`, `refreshToken` on success.
  /// Throws [FirebaseAuthRestException] on failure.
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final error = body['error'] as Map<String, dynamic>?;
      final code = error?['message'] ?? 'UNKNOWN';
      throw FirebaseAuthRestException(_friendlyMessage(code.toString()), code.toString());
    }

    return body;
  }

  /// Sign in an existing user.  Returns a map with `localId` (uid), `email`,
  /// `idToken`, `refreshToken` on success.
  /// Throws [FirebaseAuthRestException] on failure.
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      final error = body['error'] as Map<String, dynamic>?;
      final code = error?['message'] ?? 'UNKNOWN';
      throw FirebaseAuthRestException(_friendlyMessage(code.toString()), code.toString());
    }

    return body;
  }

  /// Translate Firebase REST error codes to friendly Vietnamese messages.
  static String _friendlyMessage(String code) {
    switch (code) {
      case 'EMAIL_EXISTS':
        return 'Email này đã được sử dụng!';
      case 'INVALID_EMAIL':
        return 'Email không hợp lệ!';
      case 'WEAK_PASSWORD : Password should be at least 6 characters':
      case 'WEAK_PASSWORD':
        return 'Mật khẩu phải từ 6 ký tự trở lên!';
      case 'EMAIL_NOT_FOUND':
        return 'Không tìm thấy tài khoản với email này!';
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Email hoặc mật khẩu không đúng!';
      case 'USER_DISABLED':
        return 'Tài khoản đã bị vô hiệu hóa!';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau!';
      default:
        return 'Lỗi xác thực: $code';
    }
  }
}

class FirebaseAuthRestException implements Exception {
  final String message;
  final String code;
  FirebaseAuthRestException(this.message, this.code);

  @override
  String toString() => 'FirebaseAuthRestException($code): $message';
}
