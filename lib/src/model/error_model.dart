enum ErrorStatus { server, timeout, socket, unknown, none, noContent }

class ErrorModel {
  final String title;
  final String? subtitle;
  final ErrorStatus errorStatus;

  ErrorModel({required this.title, this.subtitle, required this.errorStatus});
}
