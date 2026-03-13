import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insula/data/models/glucose_model.dart';

/// Kan şekeri ölçümleri için Firestore servisi.
class GlucoseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Son kan şekeri ölçümünü getirir.
  Future<GlucoseReading?> getLatestGlucose() async {
    final uid = _uid;
    if (uid == null) return null;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('glucoseReadings')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      final value = (data['value'] as num?)?.toInt() ?? 0;
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

      return GlucoseReading(
        id: snapshot.docs.first.id,
        value: value,
        unit: 'mg/dL',
        status: _statusFromValue(value),
        timestamp: timestamp,
      );
    } catch (e) {
      return null;
    }
  }

  String _statusFromValue(int value) {
    if (value < 70) return 'Düşük';
    if (value > 180) return 'Yüksek';
    return 'Hedefte';
  }

  /// Belirli sayıda son ölçümü getirir (detay sayfası için).
  Future<List<GlucoseReading>> getGlucoseReadings({int limit = 50}) async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('glucoseReadings')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final value = (data['value'] as num?)?.toInt() ?? 0;
        final timestamp =
            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        return GlucoseReading(
          id: doc.id,
          value: value,
          unit: 'mg/dL',
          status: _statusFromValue(value),
          timestamp: timestamp,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Yeni kan şekeri ölçümü kaydeder.
  Future<void> addGlucoseReading({
    required int value,
    DateTime? timestamp,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('glucoseReadings')
        .add({
      'value': value,
      'unit': 'mg/dL',
      'status': _statusFromValue(value),
      'timestamp': Timestamp.fromDate(timestamp ?? DateTime.now()),
    });
  }
}
