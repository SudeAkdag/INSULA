import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Uyku takip servisi – her uyku kaydını Firestore'a yazar ve akış sağlar.
class SleepService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _logsCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Kullanıcı girişi yapılmamış!');
    return _firestore.collection('users').doc(uid).collection('sleep_logs');
  }
// --- YENİ EKLENEN METOTLAR ---

  /// Kullanıcının uyku hedefini Firestore'a kaydeder
  Future<void> saveSleepTarget(int hours) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // SetOptions(merge: true) sayesinde kullanıcının diğer verileri (ad, yaş vb.) silinmez, sadece targetSleep güncellenir.
    await _firestore.collection('users').doc(uid).set({
      'targetSleep': hours,
    }, SetOptions(merge: true));
  }

  /// Kullanıcının uyku hedefini anlık olarak (Stream) dinler
  Stream<int> getSleepTarget() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(8); // Giriş yoksa varsayılan 8

      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snap) {
        final data = snap.data();
        if (data != null && data.containsKey('targetSleep')) {
          return (data['targetSleep'] as num).toInt();
        }
        return 8; // Veritabanında kayıt yoksa varsayılan 8 saat
      });
    });
  }

  /// Yeni bir uyku kaydı ekle.
  Future<void> addEntry({
    required String bedTime, // "HH:mm"
    required String wakeTime, // "HH:mm"
    required int durationMinutes,
    required String date, // "YYYY-MM-DD"
  }) async {
    await _logsCollection().add({
      'bedTime': bedTime,
      'wakeTime': wakeTime,
      'durationMinutes': durationMinutes,
      'date': date,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEntry({
    required String docId, // Güncellenecek kaydın ID'si
    required String bedTime,
    required String wakeTime,
    required int durationMinutes,
  }) async {
    await _logsCollection().doc(docId).update({
      'bedTime': bedTime,
      'wakeTime': wakeTime,
      'durationMinutes': durationMinutes,
    });
  }

  /// Tüm kayıtları (yeniden eskiye) akış olarak ver.
  Stream<List<Map<String, dynamic>>> getLogs() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('sleep_logs')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) {
                final data = Map<String, dynamic>.from(d.data());
                data['id'] = d.id;
                return data;
              }).toList());
    });
  }
}
