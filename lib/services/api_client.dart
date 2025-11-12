//Flutter uygulamamızın backend ile konuşmasını sağlayacak bir “iletim hattı” kuruyoruz.
// backende mesaj yollayıcısıFlutter uygulamamızın backend ile konuşmasını sağlayacak bir “iletim hattı” kuruyoruz.
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final Dio dio;
  ApiClient._internal(this.dio);
  factory ApiClient() {
    // Burada Dio'u oluşturacağız ve interceptors ekleyeceğiz
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
          // GetStorage’dan token oku
          final box = GetStorage();
          final token = box.read('token');

          // Eğer token varsa header’a ekl
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Debug log (opsiyonel)
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
          }

          return handler.next(options); // isteği devam ettir
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
