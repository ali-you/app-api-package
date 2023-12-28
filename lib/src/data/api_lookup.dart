import 'dart:io';

class ApiLookup {
  final String? address;

  ApiLookup({this.address});

  Future<bool> get check async {
    try {
      final result = await InternetAddress.lookup(address ?? 'example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
