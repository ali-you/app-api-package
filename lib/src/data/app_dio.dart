import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';

import '../model/error_model.dart';
import 'api_status.dart';

class AppDio {
  final _dio = Dio(BaseOptions(receiveTimeout: const Duration(seconds: 30)));

  Future<void> get(
      {required String url,
      Map<String, dynamic>? header,
      Function(String? response, int? statusCode, ApiStatus apiStatus)? onSuccess,
      Function(ErrorModel error, int? statusCode)? onError,
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
      response = await _dio.get(url,
          options: Options(responseType: ResponseType.plain, headers: header));
      if (kDebugMode) {
        print(url);
        print("status code: ${response.statusCode}");
        print("response api: ${response.data.toString()}");
      }

      switch (response.statusCode) {
        case 200:
        case 201:
          onSuccess!.call(response.data.toString(), response.statusCode, ApiStatus.success);
          break;

        case 204:
          onSuccess!.call(null, response.statusCode, ApiStatus.noContent);
          break;

        default:
          onError!.call(
              ErrorModel(
                  title: "Server is unavailable!",
                  apiStatus: ApiStatus.serverError),
              response.statusCode);
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
      onError!.call(
          ErrorModel(
              title: "Server is unavailable!",
              apiStatus: ApiStatus.serverError),
          null);
    } on TimeoutException {
      onError!.call(
          ErrorModel(title: "Poor connection!", apiStatus: ApiStatus.timeout),
          null);
    } on SocketException {
      onError!.call(
          ErrorModel(
              title: "No connection!, Check your connection!",
              apiStatus: ApiStatus.socketError),
          null);
    } catch (e) {
      if (kDebugMode) {
        print(url);
        print(e.toString());
      }
      onError!.call(
          ErrorModel(
              title: "Something wrong!", apiStatus: ApiStatus.unknownError),
          null);
    }
  }

  Future<void> post(
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
          data: body,
          options: Options(responseType: responseType, headers: header));
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
            onError(ErrorModel(
                title: "No Content", apiStatus: ApiStatus.noContent));
          }
          break;

        default:
          if (onError != null) {
            onError(ErrorModel(
                title: "Server is unavailable!",
                apiStatus: ApiStatus.serverError));
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
        onError(ErrorModel(
            title: "Server is unavailable!",
            apiStatus: ApiStatus.unknownError));
      }
    } on TimeoutException {
      if (onError != null) {
        onError(ErrorModel(
            title: "Poor connection!", apiStatus: ApiStatus.timeout));
      }
    } on SocketException {
      if (onError != null) {
        onError(ErrorModel(
            title: "No connection!, Check your connection!",
            apiStatus: ApiStatus.socketError));
      }
    } catch (e) {
      if (kDebugMode) {
        print(url);
        print(e.toString());
      }
      if (onError != null) {
        onError(ErrorModel(
            title: "Something wrong!", apiStatus: ApiStatus.unknownError));
      }
    }
  }
}
