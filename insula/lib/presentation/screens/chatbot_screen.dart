// lib/presentation/screens/chatbot/chatbot_screen.dart

import 'package:flutter/material.dart';
import '../../../data/services/gemini_service.dart';
import 'package:insula/presentation/screens/main_screen.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final List<AiChatMessage> _messages = [];

  bool _isLoading = false;
  DateTime? _lastSentAt;

  @override
  void initState() {
    super.initState();
    _addGreetingMessage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addGreetingMessage() {
    _messages.add(
      AiChatMessage(
        role: 'assistant',
        content:
            'Merhaba! Ben Insula Rehberinizim. Kan şekeri, beslenme, egzersiz, '
            'ilaç takibi ve diyabet yönetimi hakkında sorularınızı yanıtlayabilirim. '
            'Size nasıl yardımcı olabilirim? 🌱',
        suggestions: const [],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Spam koruması
    if (_lastSentAt != null &&
        DateTime.now().difference(_lastSentAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastSentAt = DateTime.now();

    setState(() {
      _messages.add(AiChatMessage(role: 'user', content: text, suggestions: []));
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final responseData = await _geminiService.sendMessage(messages: _messages);

      if (!mounted) return;
      setState(() {
        _messages.add(
          AiChatMessage(
            role: 'assistant',
            content: responseData['answer'] as String,
            suggestions: responseData['suggestions'] as List<AiSuggestion>,
          ),
        );
      });
    } catch (error) {
      debugPrint('Gemini hata: $error');

      final errorText = error.toString();
      String errorMessage;

      if (errorText.contains('QUOTA_EXCEEDED')) {
        errorMessage = 'Günlük AI kullanım limitine ulaşıldı 😔\nLütfen daha sonra tekrar deneyin.';
      } else if (errorText.contains('TIMEOUT')) {
        errorMessage = 'Yanıt süresi doldu 😔\nLütfen tekrar deneyin.';
      } else if (errorText.contains('SERVER_ERROR')) {
        errorMessage = 'Sunucu geçici olarak yoğun 😔\nBiraz sonra tekrar deneyin.';
      } else if (errorText.contains('SocketException')) {
        errorMessage = 'İnternet bağlantınızı kontrol edin.';
      } else {
        errorMessage = 'Bir hata oluştu 😔\nLütfen tekrar deneyin.';
      }

      if (!mounted) return;
      setState(() {
        _messages.add(
          AiChatMessage(role: 'assistant', content: errorMessage, suggestions: const []),
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _onWillPop() async {
    final colorScheme = Theme.of(context).colorScheme;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sohbeti Sonlandır',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Chatbot ekranından çıkmak istediğinize emin misiniz? '
          'Şu anki konuşmanız silinecektir.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Hayır, Kal',
              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Evet, Çık', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _InsulaChatAppBar(
          onBackPressed: () async {
            if (await _onWillPop() && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (ctx, index) {
                  if (index == _messages.length && _isLoading) {
                    return const _TypingIndicator();
                  }
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: message.role == 'user'
                        ? _UserBubble(text: message.content)
                        : _AssistantMessageGroup(message: message),
                  );
                },
              ),
            ),
            _MessageInputBar(
              controller: _controller,
              isLoading: _isLoading,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────

class _InsulaChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;
  const _InsulaChatAppBar({required this.onBackPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
        onPressed: onBackPressed,
      ),
      title: Text(
        'Insula Rehber',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ─────────────────────────────────────────────
// KULLANICI BALONU
// ─────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(6),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ASİSTAN MESAJ GRUBU
// ─────────────────────────────────────────────

class _AssistantMessageGroup extends StatelessWidget {
  final AiChatMessage message;
  const _AssistantMessageGroup({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantBubble(text: message.content),
        if (message.suggestions.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SuggestionCardRow(suggestions: message.suggestions),
        ],
      ],
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final String text;
  const _AssistantBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// YAZMA GÖSTERGESİ
// ─────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        ),
        child: Text(
          'Insula düşünüyor...',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ÖNERİ KARTLARI
// ─────────────────────────────────────────────

class _SuggestionCardRow extends StatelessWidget {
  final List<AiSuggestion> suggestions;
  const _SuggestionCardRow({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: suggestions
            .map((s) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _SuggestionCard(suggestion: s),
                ))
            .toList(),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final AiSuggestion suggestion;
  const _SuggestionCard({required this.suggestion});

  IconData _iconFor(String type) {
    switch (type) {
      case 'medication': return Icons.medication_rounded;
      case 'nutrition':  return Icons.restaurant_rounded;
      case 'home':       return Icons.home_rounded;
      case 'exercise':   return Icons.fitness_center_rounded;
      case 'profile':    return Icons.person_rounded;
      case 'emergency':  return Icons.emergency_rounded;
      case 'report':     return Icons.bar_chart_rounded;
      default:           return Icons.home_rounded;
    }
  }

  // Tab sırası: 0=İlaç, 1=Beslenme, 2=AnaSayfa, 3=Egzersiz, 4=Profil
  int _indexForType(String type) {
    switch (type) {
      case 'medication': return 0;
      case 'nutrition':  return 1;
      case 'home':       return 2;
      case 'exercise':   return 3;
      case 'profile':    return 4;
      case 'report':     return 2; // rapor ekranı yoksa ana sayfaya
      default:           return 2;
    }
  }

  Future<void> _onTap(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Yönlendirme Onayı',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '"${suggestion.title}" ekranına yönlendirileceksiniz. '
          'Chatbot\'tan çıkılacak ve sohbet silinecektir. '
          'Onaylıyor musunuz?',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('İptal', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Evet, Git', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    _navigate(context);
  }

void _navigate(BuildContext context) {
  final targetIndex = _indexForType(suggestion.type);
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => MainScreen(initialIndex: targetIndex),
    ),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEmergency = suggestion.type == 'emergency';

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEmergency
              ? colorScheme.errorContainer.withOpacity(0.5)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEmergency
                ? colorScheme.error.withOpacity(0.4)
                : colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEmergency
                    ? colorScheme.error.withOpacity(0.15)
                    : colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _iconFor(suggestion.type),
                color: isEmergency ? colorScheme.error : colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    suggestion.category,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MESAJ GİRİŞ ALANI
// ─────────────────────────────────────────────

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const _MessageInputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: TextField(
                  controller: controller,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Bir şey sorun...',
                    hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 48,
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      key: const ValueKey('send'),
                      onPressed: onSend,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(13),
                        backgroundColor: colorScheme.primary,
                        elevation: 0,
                        minimumSize: const Size(48, 48),
                      ),
                      child: Icon(Icons.send_rounded, color: colorScheme.onPrimary, size: 22),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}