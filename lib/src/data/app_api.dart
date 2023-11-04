import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';

import '../model/error_model.dart';

class AppApi {
  static final AppApi _instance = AppApi._internal();

  AppApi._internal();

  static AppApi get instance => _instance;

  final _dio = Dio(BaseOptions(receiveTimeout: const Duration(seconds: 30)));

  Future<void> getDio(
      {required String url,
        Map<String, dynamic>? header,
        Function(String response)? onSuccess,
        Function(ErrorModel error)? onError,
        int retryNumber = 1}) async {
    if (retryNumber > 1) {
      List<Duration> retryDelays = [];

      for (int i = 0; i < retryNumber; i++) {
        retryDelays.add(Duration(seconds: i + 1));
      }

      _dio.interceptors.add(RetryInterceptor(
        dio: _dio,
        // logPrint: print, // specify log function (optional)
        retries: retryNumber, // retry count (optional)
        retryDelays: retryDelays,
      ));
    }

    try {
      Response response;
      response =
      await _dio.get(url, options: Options(responseType: ResponseType.plain, headers: header));
      if (kDebugMode) {
        print(url);
        print("status code: ${response.statusCode}");
        print("response api: ${response.data.toString()}");
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          if (onSuccess != null) {
            onSuccess(response.data.toString());
          }
          break;

        case 204:
          if (onError != null) {
            onError(ErrorModel(title: "No Content", errorStatus: ErrorStatus.noContent));
          }
          break;

        default:
          if (onError != null) {
            onError(ErrorModel(title: "Server is unavailable!", errorStatus: ErrorStatus.server));
          }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response!.data);
          print(e.response!.headers);
          print(e.response!.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      if (onError != null) {
        onError(ErrorModel(title: "Server is unavailable!", errorStatus: ErrorStatus.server));
      }
    } on TimeoutException {
      if (onError != null) {
        onError(ErrorModel(title: "Poor connection!", errorStatus: ErrorStatus.timeout));
      }
    } on SocketException {
      if (onError != null) {
        onError(ErrorModel(
            title: "No connection!, Check your connection!", errorStatus: ErrorStatus.socket));
      }
    } catch (e) {
      if (kDebugMode) {
        print(url);
        print(e.toString());
      }
      if (onError != null) {
        onError(ErrorModel(title: "Something wrong!", errorStatus: ErrorStatus.unknown));
      }
    }
  }

  Future<void> postDio(
      {required String url,
        Map<String, dynamic>? header,
        required Map<String, dynamic> body,
        Function(dynamic response)? onSuccess,
        Function(ErrorModel error)? onError,
        ResponseType responseType = ResponseType.plain,
        int retryNumber = 1}) async {
    if (retryNumber > 1) {
      List<Duration> retryDelays = [];

      for (int i = 0; i < retryNumber; i++) {
        retryDelays.add(Duration(seconds: i + 1));
      }

      _dio.interceptors.add(RetryInterceptor(
        dio: _dio,
        // logPrint: print, // specify log function (optional)
        retries: retryNumber, // retry count (optional)
        retryDelays: retryDelays,
      ));
    }

    try {
      Response response;
      response = await _dio.post(url,
          data: body, options: Options(responseType: responseType, headers: header));
      if (kDebugMode) {
        print(url);
        print("status code: ${response.statusCode}");
        print("response api: ${response.data.toString()}");
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          if (onSuccess != null) {
            onSuccess(response.data.toString());
          }
          break;

        case 204:
          if (onError != null) {
            onError(ErrorModel(title: "No Content", errorStatus: ErrorStatus.noContent));
          }
          break;

        default:
          if (onError != null) {
            onError(ErrorModel(title: "Server is unavailable!", errorStatus: ErrorStatus.server));
          }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        if (kDebugMode) {
          print(e.response!.data);
          print(e.response!.headers);
          print(e.response!.requestOptions);
        }
      } else {
        if (kDebugMode) {
          print(e.requestOptions);
          print(e.message);
        }
      }
      if (onError != null) {
        onError(ErrorModel(title: "Server is unavailable!", errorStatus: ErrorStatus.unknown));
      }
    } on TimeoutException {
      if (onError != null) {
        onError(ErrorModel(title: "Poor connection!", errorStatus: ErrorStatus.timeout));
      }
    } on SocketException {
      if (onError != null) {
        onError(ErrorModel(
            title: "No connection!, Check your connection!", errorStatus: ErrorStatus.socket));
      }
    } catch (e) {
      if (kDebugMode) {
        print(url);
        print(e.toString());
      }
      if (onError != null) {
        onError(ErrorModel(title: "Something wrong!", errorStatus: ErrorStatus.unknown));
      }
    }
  }
}