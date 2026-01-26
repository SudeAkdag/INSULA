class GlucoseReading {
  final int value;           // Örn: 105
  final String unit;         // Örn: "mg/dL"
  final String status;       // Örn: "Normal", "Düşük"
  final DateTime timestamp;  // Ölçüm zamanı

  GlucoseReading({
    required this.value,
    this.unit = "mg/dL",
    required this.status,
    required this.timestamp,
  });
}