import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '/helpers/di.dart';
import '../../constants/app_constants.dart';
import '../endpoints.dart';
import 'log.dart';

final class DioSingleton {
  static final DioSingleton _singleton = DioSingleton._internal();
  static CancelToken cancelToken = CancelToken();
  DioSingleton._internal();

  static DioSingleton get instance => _singleton;

  late Dio dio;

  void create() {
    String? token = appData.read(kKeyAccessToken) ?? appData.read(kKeyToken);
    BaseOptions options = BaseOptions(
      baseUrl: url!,
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.ACCEPT_LANGUAGE: appData.read(kKeyCountryCode) ?? "en",
        NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
        if (token != null && token.isNotEmpty)
          NetworkConstants.AUTHORIZATION: "Bearer $token",
      },
    );
    dio = Dio(options)..interceptors.add(Logger());
  }

  void update(String auth) {
    if (kDebugMode) {
      print("Dio update with auth token");
    }
    BaseOptions options = BaseOptions(
      baseUrl: url!,
      responseType: ResponseType.json,
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.ACCEPT_LANGUAGE: appData.read(kKeyLanguage) ?? "en",
        NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
        NetworkConstants.AUTHORIZATION: "Bearer $auth",
      },
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
    );
    dio = Dio(options)..interceptors.add(Logger());
  }

  void updateLanguage(String countryCode) {
    if (kDebugMode) {
      print("Dio update language $countryCode");
    }
    String? token = appData.read(kKeyAccessToken) ?? appData.read(kKeyToken);
    BaseOptions options = BaseOptions(
      baseUrl: url!,
      responseType: ResponseType.json,
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.ACCEPT_LANGUAGE: countryCode,
        NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
        if (token != null && token.isNotEmpty)
          NetworkConstants.AUTHORIZATION: "Bearer $token",
      },
      connectTimeout: const Duration(milliseconds: 30000),
      receiveTimeout: const Duration(milliseconds: 30000),
    );
    dio = Dio(options)..interceptors.add(Logger());
  }
}

Future<Response> postHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.post(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> putHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.put(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> patchHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.patch(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> getHttp(String path, {Map<String, dynamic>? queryParameters}) =>
    DioSingleton.instance.dio.get(path, queryParameters: queryParameters, cancelToken: DioSingleton.cancelToken);

Future<Response> deleteHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.delete(path, data: data, cancelToken: DioSingleton.cancelToken);
