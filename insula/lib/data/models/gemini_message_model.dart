class GeminiMessage {
  final String role; // "user" veya "model"
  final String text;

  GeminiMessage({required this.role, required this.text});

  Map<String, dynamic> toJson() {
    return {
      "role": role,
      "parts": [
        {"text": text}
      ]
    };
  }
}