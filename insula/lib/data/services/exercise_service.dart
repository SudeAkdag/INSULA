import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/exercise_model.dart';


class ExerciseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Yeni Egzersiz Kaydetme
  Future<void> saveExercise(ExerciseModel exercise) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("Kullanıcı girişi yapılmamış!");

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('exercises')
          .add(exercise.toMap());
    } catch (e) {
      debugPrint("Kayıt Hatası: $e");
    }
  }

  // 2. Mevcut Egzersizi Güncelleme
  // ActiveTimerScreen bittiğinde dökümanı güncellemek için kullanılır.
  Future<void> updateExercise(ExerciseModel exercise) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("Kullanıcı girişi yapılmamış!");
     

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('exercises')
          .doc(exercise.id)
          .update(exercise.toMap());
      
      debugPrint("Egzersiz başarıyla güncellendi.");
    } catch (e) {
      debugPrint("Firestore Güncelleme Hatası: $e");
    }
  }

  // 3. Kullanıcının Egzersizlerini Dinleme (Stream)

 Stream<List<ExerciseModel>> getExercises() {
  // authStateChanges() bir Stream'dir.
  // asyncExpand, kullanıcı değiştiğinde eski dinlemeyi kapatıp yenisini açar.
  return _auth.authStateChanges().asyncExpand((user) {
    if (user == null) {
      return Stream.value([]); // Kullanıcı yoksa boş liste dön.
    }

    // Kullanıcı varsa o kullanıcıya ait koleksiyonu dinle.
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('exercises')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ExerciseModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  });
}
  // 4. Aylık İstatistikleri ve Karşılaştırmayı Hesaplama
  Future<Map<String, dynamic>> getMonthlyComparison() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return {'count': 0, 'calories': 0, 'avgDrop': 0, 'difference': 0.0};

    final now = DateTime.now();
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    // Verileri çek
    final thisMonthSnap = await _firestore.collection('users').doc(uid).collection('exercises')
        .where('date', isGreaterThanOrEqualTo: startOfThisMonth.toIso8601String()).get();

    final lastMonthSnap = await _firestore.collection('users').doc(uid).collection('exercises')
        .where('date', isGreaterThanOrEqualTo: startOfLastMonth.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfLastMonth.toIso8601String()).get();

    int thisMonthKcal = 0;
    double totalDrop = 0;
    int dropCount = 0;

    for (var doc in thisMonthSnap.docs) {
      final data = doc.data();
      thisMonthKcal += (data['estimatedCalories'] as num? ?? 0).toInt();
      
      // Şeker düşüşü hesapla (Egzersiz tamamlanmışsa)
      if (data['isCompleted'] == true && data['glucoseBefore'] != null && data['glucoseAfter'] != null) {
        totalDrop += (data['glucoseBefore'] - data['glucoseAfter']);
        dropCount++;
      }
    }

    int lastMonthKcal = 0;
    for (var doc in lastMonthSnap.docs) {
      lastMonthKcal += (doc.data()['estimatedCalories'] as num? ?? 0).toInt();
    }

    // Fark yüzdesi
    double kcalDiff = 0;
    if (lastMonthKcal > 0) {
      kcalDiff = ((thisMonthKcal - lastMonthKcal) / lastMonthKcal) * 100;
    }

    return {
      'count': thisMonthSnap.docs.length,
      'calories': thisMonthKcal,
      'avgDrop': dropCount > 0 ? (totalDrop / dropCount).round() : 0,
      'difference': kcalDiff,
    };
  }

 // 5. Günlük Özet Verilerini Hesaplama (Düzeltilmiş)
 Future<Map<String, dynamic>> getTodayStats() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return {'totalCalories': 0, 'totalMinutes': 0, 'intensity': "---", 'hasData': false};

    final now = DateTime.now();
    // Günü normalize et (saat/dakika farkından dolayı veri kaçırmamak için)
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .where('date', isGreaterThanOrEqualTo: todayStart)
        .get();

    int totalCalories = 0;
    int totalMinutes = 0;
    List<String> intensities = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['isCompleted'] == true) {
        totalCalories += (data['estimatedCalories'] as num? ?? 0).toInt();
        totalMinutes += (data['durationMinutes'] as num? ?? 0).toInt();
        
        // Veriyi küçük harfe çevirerek ekle (karşılaştırmayı kolaylaştırır)
        String level = (data['intensityLevel'] ?? "düşük").toString().toLowerCase();
        intensities.add(level);
      }
    }

    String dominantIntensity = "---";
    
    // Veritabanındaki "YÜKSEK YOĞUNLUK" veya "Yüksek" gibi tüm varyasyonları yakalar
    if (intensities.any((e) => e.contains("yüksek"))) {
      dominantIntensity = "Yüksek";
    } else if (intensities.any((e) => e.contains("orta"))) {
      dominantIntensity = "Orta";
    } else if (intensities.isNotEmpty) {
      dominantIntensity = "Düşük";
    }

    return {
      'totalCalories': totalCalories,
      'totalMinutes': totalMinutes,
      'intensity': dominantIntensity,
      'hasData': intensities.isNotEmpty,
    };
 }

  // 6. Haftalık Grafik Verilerini Çekme (Son 7 Gün)
  // ExerciseService içindeki ilgili kısmı şu mantıkla güncelle:
Future<List<double>> getWeeklyCalories() async {
  final String? uid = _auth.currentUser?.uid;
  if (uid == null) return List.filled(7, 0.0);

  // 1. Her zaman 7 elemanlı ve içi 0 dolu bir liste ile başla
  List<double> weeklyValues = List.filled(7, 0.0);

  try {
    final now = DateTime.now();
    // Bu haftanın Pazartesi gününü bul
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    
    String startOfWeekStr = startOfWeek.toIso8601String();

    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .where('date', isGreaterThanOrEqualTo: startOfWeekStr)
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['isCompleted'] == true) {
        // 2. Kayıt tarihini parse et
        DateTime recordDate = DateTime.parse(data['date']);
        
        // 3. DOĞRU İNDEKSİ HESAPLA: Pzt=1, Sal=2... Paz=7
        // İndeks için 1 çıkarıyoruz (0-6 arası olması için)
        int dayIndex = recordDate.weekday - 1;

        if (dayIndex >= 0 && dayIndex < 7) {
          // 4. Veriyi doğrudan o güne yaz, üstüne ekle (o gün birden fazla spor olabilir)
          weeklyValues[dayIndex] += (data['estimatedCalories'] as num? ?? 0).toDouble();
        }
      }
    }
  } catch (e) {
    debugPrint("Hata: $e");
  }
  
  return weeklyValues;
}


// 7. Belirli Alanları Güncelleme (Düzenleme Pop-up'ı için)
  Future<void> updateExerciseFields({
    required String id, 
    required int duration, 
    double? sugarBefore
  }) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("Kullanıcı girişi yapılmamış!");

      // Süre değiştiği için tahmini kaloriyi de yeniden hesaplayalım (Dakika başı ~7 kcal gibi genel bir kabulle)
      // Eğer modelinde özel bir çarpan varsa onu da kullanabilirsin.
      int newCalories = duration * 7; 

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('exercises')
          .doc(id)
          .update({
            'durationMinutes': duration,
            'glucoseBefore': sugarBefore,
            'estimatedCalories': newCalories, // Süre uzarsa/kısalırsa kalori de güncellensin
          });
          
      debugPrint("Alanlar başarıyla güncellendi.");
    } catch (e) {
      debugPrint("Firestore Alan Güncelleme Hatası: $e");
    }
  }


  Future<void> deleteExercise(String docId) async {
  try {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // ÖNEMLİ: users -> UID -> exercises -> DOC_ID
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .doc(docId) // Buradaki ID Firestore'daki otomatik ID olmalı
        .delete();
        
    debugPrint("Firestore'dan silindi: $docId");
  } catch (e) {
    debugPrint("Silme hatası: $e");
  }
}
}