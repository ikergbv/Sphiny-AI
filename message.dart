class Message {
  final String role;
  final dynamic content; // String or List<Map<String, dynamic>>
  final DateTime timestamp;
  final String id;

  Message({
    required this.role,
    required this.content,
    DateTime? timestamp,
    String? id,
  })  : timestamp = timestamp ?? DateTime.now(),
        id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'model';

  String get textContent {
    if (content is String) return content;
    if (content is List) {
      final parts = content as List;
      return parts.map((part) => part['text'] ?? '').join('');
    }
    return '';
  }
}

class Completion {
  final String text;

  Completion({required this.text});
}

class GeminiException implements Exception {
  final int statusCode;
  final String message;

  GeminiException({required this.statusCode, required this.message});

  @override
  String toString() => 'GeminiException: $statusCode - $message';
}
