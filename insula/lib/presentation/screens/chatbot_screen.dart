import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme/app_colors.dart'; 
import '../../data/models/chat_message_model.dart';
import 'package:insula/data/services/azure_openai_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  late final AzureOpenAIService _aiService;
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _aiService = AzureOpenAIService(
      apiKey: dotenv.env['AZURE_OPENAI_KEY'] ?? '',
      endpoint: dotenv.env['AZURE_OPENAI_ENDPOINT'] ?? '',
      deploymentName: dotenv.env['AZURE_OPENAI_DEPLOYMENT_NAME'] ?? '',
    );
  }

  // ... (Firebase veri çekme ve mesaj gönderme fonksiyonların aynı kalıyor)
  Future<String> _fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return "";
      var sugarDoc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('daily_data').orderBy('date', descending: true).limit(1).get();
      var waterDoc = await FirebaseFirestore.instance.collection('users').doc(uid).collection('water_data').orderBy('date', descending: true).limit(1).get();
      String dataSummary = "";
      if (sugarDoc.docs.isNotEmpty) dataSummary += "Son Şeker: ${sugarDoc.docs.first['glucose']} mg/dL. ";
      if (waterDoc.docs.isNotEmpty) dataSummary += "Bugünkü Su: ${waterDoc.docs.first['amount']} ml.";
      return dataSummary.isEmpty ? "Henüz veri girilmemiş." : dataSummary;
    } catch (e) {
      return "Veri çekilemedi.";
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text;
    setState(() {
      _messages.insert(0, ChatMessage(text: userText, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    String healthData = await _fetchUserData();
    final response = await _aiService.getAiResponse(userText, firebaseData: healthData);
    if (mounted) {
      setState(() {
        _messages.insert(0, ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sayfa arka planı temiz beyaz
      appBar: AppBar(
        title: const Text(
          "Insula Asistan", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold) // Siyahlığı düzelttik
        ), 
        backgroundColor: AppColors.secondary,
        iconTheme: const IconThemeData(color: Colors.white), // Geri butonu beyaz
        elevation: 2,
      ),
      body: SafeArea( // Telefonun alt barına yapışmasını engeller
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
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
          color: isUser ? AppColors.primary : AppColors.secondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
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
            fontSize: 15,
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Bir şey sorun...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar( // Butonun etrafı daha belirgin
            backgroundColor: AppColors.primary,
            radius: 24,
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