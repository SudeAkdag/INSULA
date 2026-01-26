class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isCritical; // Şeker uyarısı gibi durumlar için farklı renk/ikon
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isCritical = false,
    this.isRead = false,
  });
}