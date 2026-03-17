import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/theme/app_colors.dart'; // Kendi renk dosyan
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
    // .env dosyasından anahtarları güvenle çekiyoruz
    _aiService = AzureOpenAIService(
      apiKey: dotenv.env['AZURE_OPENAI_KEY'] ?? '',
      endpoint: dotenv.env['AZURE_OPENAI_ENDPOINT'] ?? '',
      deploymentName: dotenv.env['AZURE_OPENAI_DEPLOYMENT_NAME'] ?? '',
    );
  }

  // Firebase'den kullanıcının son verilerini toplayan fonksiyon
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
      appBar: AppBar(title: const Text("Insula Asistan"), backgroundColor: AppColors.secondary),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Bir şey sorun..."))),
          IconButton(icon: const Icon(Icons.send, color: AppColors.primary), onPressed: _sendMessage),
        ],
      ),
    );
  }
}