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
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value([]);
      }

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
  Future<Map<String, dynamic>> getMonthlyComparison() async {
  final String? uid = _auth.currentUser?.uid;
  if (uid == null) return {'count': 0, 'totalCalories': 0.0, 'difference': 0.0};

  final now = DateTime.now();
  
  // Veritabanındaki "2026-04-19..." formatıyla eşleşmesi için ISO String kullanıyoruz
  // .split('T')[0] kullanarak sadece tarih kısmını (YYYY-MM-DD) karşılaştırmak en sağlıklısıdır
  final String thisMonthPrefix = "${now.year}-${now.month.toString().padLeft(2, '0')}";
  
  // Geçen ayı hesapla
  int lastMonth = now.month - 1;
  int lastYear = now.year;
  if (lastMonth == 0) {
    lastMonth = 12;
    lastYear -= 1;
  }
  final String lastMonthPrefix = "$lastYear-${lastMonth.toString().padLeft(2, '0')}";

  try {
    // Tüm egzersizleri çek (Küçük veri seti olduğu için filtreyi kod içinde yapmak daha hızlı ve hatasızdır)
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .get();

    double thisMonthKcal = 0.0;
    int thisMonthCount = 0;
    double lastMonthKcal = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String? dateStr = data['date'] as String?;
      
      if (dateStr != null) {
        // Bu ayın verisi mi?
        if (dateStr.startsWith(thisMonthPrefix)) {
          if (data['isCompleted'] == true) {
            thisMonthCount++;
            thisMonthKcal += (data['estimatedCalories'] as num? ?? 0).toDouble();
          }
        } 
        // Geçen ayın verisi mi?
        else if (dateStr.startsWith(lastMonthPrefix)) {
          if (data['isCompleted'] == true) {
            lastMonthKcal += (data['estimatedCalories'] as num? ?? 0).toDouble();
          }
        }
      }
    }

    // Fark hesaplama
    double diff = 0.0;
    if (lastMonthKcal > 0) {
      diff = ((thisMonthKcal - lastMonthKcal) / lastMonthKcal) * 100;
    } else if (thisMonthKcal > 0) {
      diff = 100.0;
    }

    return {
      'count': thisMonthCount,
      'totalCalories': thisMonthKcal,
      'difference': diff,
    };
  } catch (e) {
    debugPrint("❌ Ay Özeti Hatası: $e");
    return {'count': 0, 'totalCalories': 0.0, 'difference': 0.0};
  }
}

  // 5. Günlük Özet Verilerini Hesaplama (Stream)
  Stream<Map<String, dynamic>> getTodayStatsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value({
          'totalCalories': 0,
          'totalMinutes': 0,
          'intensity': "---",
          'hasData': false
        });
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('exercises')
          .where('date',
              isGreaterThanOrEqualTo: todayStart.toUtc(),
              isLessThan: tomorrowStart.toUtc())
          .snapshots()
          .map((snapshot) {
        int totalCalories = 0;
        int totalMinutes = 0;
        List<String> intensities = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['isCompleted'] == true) {
            totalCalories += (data['estimatedCalories'] as num? ?? 0).toInt();
            totalMinutes += (data['durationMinutes'] as num? ?? 0).toInt();

            String level =
                (data['intensityLevel'] ?? "düşük").toString().toLowerCase();
            intensities.add(level);
          }
        }

        String dominantIntensity = "---";

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
      });
    });
  }

  // 6. Haftalık Grafik Verilerini Çekme (Stream)
  Stream<List<double>> getWeeklyCaloriesStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(List.filled(7, 0.0));
      }

      final now = DateTime.now();
      final startOfWeek =
          DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('exercises')
          .where('date', isGreaterThanOrEqualTo: startOfWeek.toUtc())
          .where('date', isLessThan: endOfWeek.toUtc())
          .snapshots()
          .map((snapshot) {
        List<double> weeklyValues = List.filled(7, 0.0);

        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['isCompleted'] == true) {
            // ✅ Tarih parse et ve yerel saate çevir
            DateTime recordDate = DateTime.parse(data['date']).toLocal();

            // ✅ Yerel tarihten günü al
            int dayIndex = recordDate.weekday - 1;

            if (dayIndex >= 0 && dayIndex < 7) {
              weeklyValues[dayIndex] +=
                  (data['estimatedCalories'] as num? ?? 0).toDouble();
            }
          }
        }

        return weeklyValues;
      });
    });
  }

  // 7. Belirli Alanları Güncelleme
  Future<void> updateExerciseFields({
    required String id,
    required int duration,
    double? sugarBefore,
  }) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("Kullanıcı girişi yapılmamış!");

      int newCalories = duration * 7;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('exercises')
          .doc(id)
          .update({
            'durationMinutes': duration,
            'glucoseBefore': sugarBefore,
            'estimatedCalories': newCalories,
          });

      debugPrint("Alanlar başarıyla güncellendi.");
    } catch (e) {
      debugPrint("Firestore Alan Güncelleme Hatası: $e");
    }
  }

  // 8. Egzersiz Silme
  Future<void> deleteExercise(String docId) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('exercises')
          .doc(docId)
          .delete();

      debugPrint("Firestore'dan silindi: $docId");
    } catch (e) {
      debugPrint("Silme hatası: $e");
    }
  }

  // ✅ FutureBuilder ile çalışacak olan 'getTodayStats' metodu
  Future<Map<String, dynamic>> getTodayStats() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return {
        'totalCalories': 0.0,
        'totalMinutes': 0,
        'intensity': "---",
        'hasData': false
      };
    }

    // Bugünün başlangıcı ve sonu (UTC formatında Firestore sorgusu için)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('exercises')
          .where('date', isGreaterThanOrEqualTo: todayStart.toUtc().toIso8601String())
          .where('date', isLessThan: tomorrowStart.toUtc().toIso8601String())
          .get();

      // ✅ Değişkenleri doğru tiplerle başlatıyoruz
      double totalCalories = 0.0;
      int totalMinutes = 0;
      List<String> intensities = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Sadece tamamlanmış egzersizleri topluyoruz
        if (data['isCompleted'] == true) {
          // ✅ Veriyi num olarak alıp double'a güvenle çeviriyoruz
          totalCalories += (data['estimatedCalories'] as num? ?? 0.0).toDouble();
          totalMinutes += (data['durationMinutes'] as num? ?? 0).toInt();

          if (data['intensityLevel'] != null) {
            intensities.add(data['intensityLevel'].toString());
          }
        }
      }

      // En yüksek yoğunluğu belirleme mantığı
      String dominantIntensity = "---";
      if (intensities.any((e) => e.toUpperCase().contains("YÜKSEK"))) {
        dominantIntensity = "Yüksek";
      } else if (intensities.any((e) => e.toUpperCase().contains("ORTA"))) {
        dominantIntensity = "Orta";
      } else if (intensities.isNotEmpty) {
        dominantIntensity = "Düşük";
      }

      // ✅ Map dönerken anahtarların doğruluğundan eminiz
      return {
        'totalCalories': totalCalories, // double
        'totalMinutes': totalMinutes,   // int
        'intensity': dominantIntensity,
        'hasData': intensities.isNotEmpty,
      };
    } catch (e) {
      debugPrint("getTodayStats Hatası: $e");
      return {'totalCalories': 0.0, 'totalMinutes': 0, 'intensity': "---", 'hasData': false};
    }
  }
  
}