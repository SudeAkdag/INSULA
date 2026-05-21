// lib/data/services/gemini_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:insula/data/models/chat_message_model.dart';

export 'package:insula/data/models/chat_message_model.dart';

class GeminiService {
  // DAHA STABİL + DAHA UCUZ
static const String _model = 'gemini-2.5-flash';

static const String _baseUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _systemInstruction = """
Sen INSULA adlı diyabet yönetim uygulamasının yapay zeka rehberisin. Adın Insula Rehber.



SADECE JSON döndür. Başka HİÇBİR şey yazma. Markdown yasak. Açıklama yasak.

Yanıt formatı kesinlikle bu olmalı:
{"answer":"buraya düz metin yanıt","suggestions":[]}

Kurallar:
- Türkçe yaz
- answer içinde ** veya * kullanma, düz metin yaz
- Sen INSULA diyabet uygulamasının asistanısın
- Tıbbi teşhis koyma, yanıt sonuna "Bu bir yapay zeka analizidir, tıbbi tavsiye yerine geçmez." ekle
- suggestions type değerleri: home, exercise, medication, nutrition, report, profile, emergency
- Max 2 suggestions
- Diyabet dışı sorularda suggestions boş bırak: []
- JSON dışında tek karakter bile yazma
""";

static const List<Map<String, dynamic>> _fewShots = [
  {
    'role': 'user',
    'parts': [{'text': 'Akşam ne yiyebilirim?'}]
  },
  {
    'role': 'model',
    'parts': [{'text': '{"answer":"Akşam yemeği için ızgara tavuk veya balık yanında bol salata iyi bir seçim olabilir. Tam tahıllı ekmek veya bulgur pilavı da tercih edebilirsin. Şekerli ve işlenmiş gıdalardan uzak durman kan şekerini dengelemeye yardımcı olur. Bu bir yapay zeka analizidir, tıbbi tavsiye yerine geçmez.","suggestions":[{"title":"Beslenme Takibi","type":"nutrition","category":"Beslenme"}]}'}]
  },
  {
    'role': 'user',
    'parts': [{'text': 'Kan şekerim düştü'}]
  },
  {
    'role': 'model',
    'parts': [{'text': '{"answer":"Kan şekerin düşük olabilir. Hemen 15 gram hızlı karbonhidrat al, meyve suyu veya glikoz tableti işe yarar. 15 dakika sonra tekrar ölç. Belirtiler şiddetliyse 112 yi ara. Bu bir yapay zeka analizidir, tıbbi tavsiye yerine geçmez.","suggestions":[{"title":"Acil Durum","type":"emergency","category":"Acil"}]}'}]
  },
  {
    'role': 'user',
    'parts': [{'text': 'Egzersiz ekranına git'}]
  },
  {
    'role': 'model',
    'parts': [{'text': '{"answer":"Seni Egzersiz Takibi ekranına yönlendiriyorum.","suggestions":[{"title":"Egzersiz Takibi","type":"exercise","category":"Egzersiz"}]}'}]
  },
];

  Future<Map<String, dynamic>> sendMessage({
    required List<AiChatMessage> messages,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('API_KEY_MISSING');
    }

    final uri = Uri.parse('$_baseUrl?key=$_apiKey');

    // TOKEN OPTİMİZASYONU
    final limitedMessages = messages.length > 8
        ? messages.sublist(messages.length - 8)
        : messages;

    final history = limitedMessages
        .where((m) => m.role != 'system')
        .map((m) => m.toGeminiPart())
        .toList();

    final body = {
      'system_instruction': {
        'parts': [
          {'text': _systemInstruction}
        ]
      },
      'contents': [
        ..._fewShots,
        ...history,
      ],
      'generationConfig': {
        'temperature': 0.7,

        // TOKEN TASARRUFU
        'maxOutputTokens': 500,

        
      },
    };

    debugPrint(
      'Gemini request -> messageCount: ${history.length}',
    );

    late http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw Exception('TIMEOUT');
    }

    final decodedBody = utf8.decode(response.bodyBytes);

    debugPrint('Gemini status: ${response.statusCode}');

    // SUCCESS
    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final data = jsonDecode(decodedBody);

      final rawContent = data['candidates']?[0]?['content']
          ?['parts']?[0]?['text'];

      if (rawContent == null ||
          rawContent.toString().trim().isEmpty) {
        throw Exception('EMPTY_RESPONSE');
      }

      return _parseResponse(rawContent.toString());
    }

    // RATE LIMIT
    if (response.statusCode == 429) {
      throw Exception('QUOTA_EXCEEDED');
    }

    // SERVER ERROR
    if (response.statusCode >= 500) {
      throw Exception('SERVER_ERROR');
    }

    throw Exception(
      'API_ERROR_${response.statusCode}',
    );
  }

  Map<String, dynamic> _parseResponse(String rawContent) {
    try {
      final cleaned = rawContent
          .replaceAll(
            RegExp(r'^```json\s*', multiLine: true),
            '',
          )
          .replaceAll(
            RegExp(r'```\s*$', multiLine: true),
            '',
          )
          .trim();

      final parsedJson =
          jsonDecode(cleaned) as Map<String, dynamic>;

      final answer = parsedJson['answer']
              ?.toString()
              .trim() ??
          'Şu an yanıt oluşturamıyorum.';

      final rawSuggestions =
          parsedJson['suggestions'] as List? ?? [];

      final suggestions = rawSuggestions
          .map(
            (s) => AiSuggestion.fromJson(
              s as Map<String, dynamic>,
            ),
          )
          .toList();

      return {
        'answer': answer,
        'suggestions': suggestions,
      };
    } catch (e) {
      debugPrint('JSON parse error: $e');

      return {
        'answer': rawContent,
        'suggestions': <AiSuggestion>[],
      };
    }
  }
}