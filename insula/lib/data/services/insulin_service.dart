import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insula/data/models/insulin_log_model.dart';

/// İnsülin kayıtları için Firestore servisi.
/// Veriler asenkron çekilir, UI donması önlenir.
class InsulinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Son 24 saatteki insülin kayıtlarını getirir.
  /// Sadece hızlı etkili insülin için aktif süre hesaplanır.
  Future<List<InsulinLog>> getRecentInsulinLogs({int limit = 20}) async {
    final uid = _uid;
    if (uid == null) return [];

    try {
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('insulinLogs')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(cutoff))
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => InsulinLog.fromFirestore(doc))
          .where((log) => log.isActive)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// En son aktif insülin kaydını getirir (süre gösterimi için).
  Future<InsulinLog?> getLatestActiveInsulin() async {
    final logs = await getRecentInsulinLogs(limit: 10);
    if (logs.isEmpty) return null;
    return logs.first;
  }

  /// Yeni insülin kaydı ekler.
  Future<void> addInsulinLog({
    required double units,
    required String type,
    String? note,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('insulinLogs')
        .add(InsulinLog(
          id: '',
          units: units,
          type: type,
          timestamp: DateTime.now(),
          note: note,
        ).toMap());
  }

  /// Bugün alınan toplam insülin (ünite).
  Future<double> getTodayInsulinTotal() async {
    final uid = _uid;
    if (uid == null) return 0;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('insulinLogs')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .orderBy('timestamp')
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        final ts = (doc.data()['timestamp'] as Timestamp?)?.toDate();
        if (ts != null && ts.isBefore(endOfDay)) {
          final units = (doc.data()['units'] as num?)?.toDouble() ?? 0;
          total += units;
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Aktif insülin stream'i - anlık güncellemeler için.
  Stream<InsulinLog?> watchLatestActiveInsulin() {
    final uid = _uid;
    if (uid == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('insulinLogs')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      for (final doc in snapshot.docs) {
        final log = InsulinLog.fromFirestore(doc);
        if (log.isActive) return log;
      }
      return null;
    });
  }
}
