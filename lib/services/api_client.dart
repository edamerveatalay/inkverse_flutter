//Flutter uygulamamızın backend ile konuşmasını sağlayacak bir “iletim hattı” kuruyoruz.
// backende mesaj yollayıcısıFlutter uygulamamızın backend ile konuşmasını sağlayacak bir “iletim hattı” kuruyoruz.
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio dio;
  ApiClient._internal(this.dio);
  factory ApiClient() {
    final baseOptions = BaseOptions(
      baseUrl: 'http://10.0.2.2:8000', // senin backend adresin
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    );

    final dio = Dio(baseOptions);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('TOKEN: $token');
          }

          return handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
          }
          return handler.next(response); // cevabı devam ettir
        },
        onError: (DioError e, handler) {
          if (kDebugMode) {
            print(
              'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            );
          }
          return handler.next(e); // hatayı devam ettir
        },
      ),
    );
    return ApiClient._internal(dio);
  }
}
