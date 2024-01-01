import 'dart:async';

import 'package:app_api/src/data/api_lookup.dart';
import 'package:app_api/src/data/app_dio.dart';
import 'package:dio/dio.dart';

import '../../app_api.dart';
import '../model/error_model.dart';
import 'app_http.dart';

class AppApi {
  static final AppApi _instance = AppApi._internal();

  AppApi._internal();

  static AppApi get instance => _instance;

  final AppHttp _appHttp = AppHttp();

  final AppDio _appDio = AppDio();

  final ApiLookup _apiLookup = ApiLookup();

  Future<void> getDio(
      {required String url,
      Map<String, dynamic>? header,
      Function(String? response, int? statusCode, ApiStatus apiStatus)? onSuccess,
      Function(ErrorModel error, int? statusCode)? onError,
      int retryNumber = 1}) async {
    if (await _apiLookup.check) {
      await _appDio.get(
        url: url,
        header: header,
        onSuccess: onSuccess,
        onError: onError,
        retryNumber: retryNumber);
    }else {
      onError!.call(ErrorModel(title: "No internet!", apiStatus: ApiStatus.noInternet), null);
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
    if (await _apiLookup.check) {
      await _appDio.post(
        url: url,
        body: body,
        responseType: responseType,
        header: header,
        onSuccess: onSuccess,
        onError: onError,
        retryNumber: retryNumber);
    }
  }

  Future<void> downloadHttp(
      {required String url,
      Map<String, dynamic>? header,
      Function(int downloaded, double percent)? onProgress,
      Function(List<int> data)? onDone,
      Function(ErrorModel error)? onError,
      bool showException = false}) async {
    if (await _apiLookup.check) {
      await _appHttp.download(
        url: url,
        header: header,
        onProgress: onProgress,
        onDone: onDone,
        onError: onError,
        showException: showException);
    }
  }
}
