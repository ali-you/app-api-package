import '../data/api_status.dart';

class ErrorModel {
  final String title;
  final String? subtitle;
  final ApiStatus apiStatus;

  ErrorModel({required this.title, this.subtitle, required this.apiStatus});
}
