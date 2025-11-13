import 'api_client.dart';
import 'package:dio/dio.dart';

class AuthApi {
  final ApiClient _apiClient = ApiClient();

  Future<Response> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/signin/', // backend ile birebir eşleşiyor
        data: {'email': email, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/users',
        data: {'username': username, 'email': email, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
