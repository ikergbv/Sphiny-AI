import 'package:dio/dio.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    _initializeService();
  }

  void _initializeService() {
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY must be provided via --dart-define');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://generativelanguage.googleapis.com/v1',
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Dio get dio => _dio;
  String get authApiKey => apiKey;
}
