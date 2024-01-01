import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../model/error_model.dart';
import 'api_status.dart';

class AppHttp {
  Future<void> download(
      {required String url,
      Map<String, dynamic>? header,
      Function(int downloaded, double percent)? onProgress,
      Function(List<int> data)? onDone,
      Function(ErrorModel error)? onError,
      bool showException = false}) async {
    try {
      final client = http.Client();
      http.StreamedResponse response =
          await client.send(http.Request("GET", Uri.parse(url)));

      if (response.statusCode == 200) {
        var length = response.contentLength ?? 0;
        List<int> bytes = [];
        var received = 0;
        response.stream.listen((value) {
          bytes.addAll(value);
          received += value.length;
          if (length == 0) {
            onProgress?.call(received, 0);
          } else {
            onProgress?.call(received, received / length);
          }
        }).onDone(() {
          onDone?.call(bytes);
        });
      } else {
        onError?.call(ErrorModel(
            title: "Server is unavailable!", apiStatus: ApiStatus.serverError));
      }
    } on SocketException catch (e) {
      onError?.call(ErrorModel(
          title: "No connection!, Check your connection!",
          apiStatus: ApiStatus.socketError));
      if (showException) throw Exception(e);
    } on TimeoutException catch (e) {
      onError?.call(ErrorModel(
          title: "Poor connection!", apiStatus: ApiStatus.timeout));
      if (showException) throw Exception(e);
    } catch (e) {
      onError?.call(ErrorModel(
          title: "Something wrong!", apiStatus: ApiStatus.unknownError));
      if (showException) throw Exception(e);
    }
  }
}
