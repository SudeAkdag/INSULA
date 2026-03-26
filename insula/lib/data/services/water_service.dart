import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Su takip servisi – her içme kaydını Firestore'a yazar ve akış sağlar.
class WaterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _logsCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Kullanıcı girişi yapılmamış!');
    return _firestore.collection('users').doc(uid).collection('water_logs');
  }

  /// Yeni bir su içme kaydı ekle.
  Future<void> addEntry({required double amountMl}) async {
    final now = DateTime.now();
    await _logsCollection().add({
      'amountMl': amountMl,
      'date':
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
// --- YENİ EKLENEN METOTLAR ---

  /// Kullanıcının su hedefini (ml cinsinden) Firestore'a kaydeder
  Future<void> saveWaterTarget(double ml) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // SetOptions(merge: true) ile diğer kullanıcı verilerini bozmadan sadece hedefi güncelliyoruz
    await _firestore.collection('users').doc(uid).set({
      'targetWater': ml,
    }, SetOptions(merge: true));
  }

  /// Kullanıcının su hedefini anlık olarak (Stream) dinler
  Stream<double> getWaterTarget() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(2500.0); // Varsayılan 2.5 Litre (2500 ml)
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snap) {
        final data = snap.data();
        if (data != null && data.containsKey('targetWater')) {
          return (data['targetWater'] as num).toDouble();
        }
        return 2500.0; // Veritabanında henüz kayıt yoksa varsayılanı döndür
      });
    });
  }

  /// Belirtilen tarihe ait tüm su içme kayıtlarını Firestore'dan siler.
  Future<void> clearTodayEntries(String dateStr) async {
    try {
      // O güne ait tüm kayıtları getir
      final snap =
          await _logsCollection().where('date', isEqualTo: dateStr).get();

      if (snap.docs.isEmpty) return; // Silinecek kayıt yoksa işlemi bitir

      // Performanslı toplu silme işlemi için batch oluştur
      final batch = _firestore.batch();

      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }

      // Silme işlemlerini onayla ve uygula
      await batch.commit();
    } catch (e) {
      throw Exception('Kayıtlar silinirken bir hata oluştu: $e');
    }
  }

  /// Tüm kayıtları (yeniden eskiye) akış olarak ver.
  Stream<List<Map<String, dynamic>>> getLogs() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('water_logs')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) {
                final data = Map<String, dynamic>.from(d.data());
                data['id'] = d.id;
                return data;
              }).toList());
    });
  }

  /// Bugünün toplam su miktarını döndür (anlık snapshot).
  Future<double> getTodayTotal() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final snap =
        await _logsCollection().where('date', isEqualTo: dateStr).get();
    double total = 0;
    for (final doc in snap.docs) {
      total += (doc.data()['amountMl'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }
}
