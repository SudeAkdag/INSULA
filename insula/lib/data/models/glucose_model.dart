class GlucoseReading {
  final String? id; // Firestore doc id
  final int value;
  final String unit;
  final String status;
  final DateTime timestamp;

  GlucoseReading({
    this.id,
    required this.value,
    this.unit = "mg/dL",
    required this.status,
    required this.timestamp,
  });

  /// Hedef aralığa göre durum hesaplar (min <= value <= max → Normal)
  static String statusFromRange(int value, int targetMin, int targetMax) {
    if (value < targetMin) return 'Düşük';
    if (value > targetMax) return 'Yüksek';
    return 'Hedefte';
  }
}