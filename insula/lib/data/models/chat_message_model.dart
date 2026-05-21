class AiChatMessage {
  final String role;
  final String content;
  final List<AiSuggestion> suggestions;

  AiChatMessage({
    required this.role,
    required this.content,
    this.suggestions = const [],
  });

  Map<String, dynamic> toGeminiPart() {
    return {
      'role': role == 'user' ? 'user' : 'model',
      'parts': [
        {
          'text': content,
        }
      ],
    };
  }

  factory AiChatMessage.fromJson(
    Map<String, dynamic> json,
  ) {
    return AiChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      suggestions: (json['suggestions'] as List?)
              ?.map(
                (e) => AiSuggestion.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'suggestions':
          suggestions.map((e) => e.toJson()).toList(),
    };
  }
}

class AiSuggestion {
  final String title;
  final String type;
  final String category;

  AiSuggestion({
    required this.title,
    required this.type,
    required this.category,
  });

  factory AiSuggestion.fromJson(
    Map<String, dynamic> json,
  ) {
    return AiSuggestion(
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'category': category,
    };
  }
}