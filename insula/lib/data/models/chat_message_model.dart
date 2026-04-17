class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text, 
    required this.isUser, 
    DateTime? time, // Yerel parametre
  }) : time = time ?? DateTime.now(); // 'this.' kaldırıldı
}