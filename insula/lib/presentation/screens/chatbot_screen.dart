import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; 
import '../../../data/models/chat_message_model.dart';
import '../../../data/services/gemini_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final GeminiService _aiService; 
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Gemini servisini başlatıyoruz
    _aiService = GeminiService(); 
  }

  // Veritabanı sınıfları hazır olana kadar bu fonksiyonu sade tuttuk
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userText = _controller.text;
    
    setState(() {
      // Kullanıcının mesajını listeye ekle
      _messages.insert(0, ChatMessage(text: userText, isUser: true));
      _isLoading = true;
    });
    
    _controller.clear();
    
    // ŞİMDİLİK: Sadece kullanıcı metnini gönderiyoruz, veritabanı okuması yapmıyoruz
    final response = await _aiService.getAiResponse(userText);
    
    if (mounted) {
      setState(() {
        // AI'dan gelen cevabı listeye ekle
        _messages.insert(0, ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Insula Asistan", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ), 
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Mesajlar alttan yukarı doğru akar
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
              ),
            ),
            if (_isLoading) 
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    bool isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
        ),
        child: Text(
          message.text, 
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87, 
            fontSize: 15
          )
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.grey[200]!))
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100], 
                borderRadius: BorderRadius.circular(30)
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(), // Enter tuşu ile gönderim
                decoration: const InputDecoration(
                  hintText: "Bir şey sorun...", 
                  border: InputBorder.none
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}