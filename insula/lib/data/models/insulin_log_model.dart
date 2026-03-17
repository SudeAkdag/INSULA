import 'package:cloud_firestore/cloud_firestore.dart';

/// İnsülin kaydı modeli.
/// Aktif insülin süresi hesaplaması için kullanılır.
class InsulinLog {
  final String id;
  final double units;
  final String type;  // Hızlı etkili, Uzun etkili, Karma
  final String site;  // Karın, Kol, Bacak, Kalça
  final DateTime timestamp;
  final String? note;

  /// Hızlı etkili insülin etki süresi (saat)
  static const double fastActingDurationHours = 3.5;

  /// Uzun etkili insülin etki süresi (saat)
  static const double longActingDurationHours = 24.0;

  InsulinLog({
    required this.id,
    required this.units,
    required this.type,
    this.site = 'Karın',
    required this.timestamp,
    this.note,
  });

  /// Bu dozun etki süresi (saat)
  double get durationHours {
    if (type.toLowerCase().contains('hızlı') ||
        type.toLowerCase().contains('kısa')) {
      return fastActingDurationHours;
    }
    return longActingDurationHours;
  }

  /// Tahmini bitiş zamanı
  DateTime get estimatedEndTime =>
      timestamp.add(Duration(milliseconds: (durationHours * 3600 * 1000).toInt()));

  /// Kalan süre (şu an ile bitiş arası)
  Duration get remainingDuration {
    final now = DateTime.now();
    final end = estimatedEndTime;
    if (now.isAfter(end)) return Duration.zero;
    return end.difference(now);
  }

  /// Aktif mi (hâlâ etkili mi)
  bool get isActive => DateTime.now().isBefore(estimatedEndTime);

  factory InsulinLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return InsulinLog(
      id: doc.id,
      units: (data['units'] as num?)?.toDouble() ?? 0,
      type: data['type'] as String? ?? 'Hızlı etkili',
      site: data['site'] as String? ?? 'Karın',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'units': units,
      'type': type,
      'site': site,
      'timestamp': Timestamp.fromDate(timestamp),
      if (note != null) 'note': note,
    };
  }
}
