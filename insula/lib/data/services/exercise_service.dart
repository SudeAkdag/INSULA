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
      
    debugPrint("Yeni egzersiz başarıyla eklendi."); // print yerine debugPrint
    } catch (e) {
      debugPrint("Firestore Kayıt Hatası: $e");
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
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExerciseModel.fromMap(doc.id, doc.data()))
            .toList());
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

  // 5. Günlük Özet Verilerini Hesaplama
  Future<Map<String, dynamic>> getTodayStats() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return {'totalCalories': 0, 'totalMinutes': 0, 'intensity': "---", 'hasData': false};

    final now = DateTime.now();
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
        intensities.add(data['intensityLevel'] ?? "Düşük");
      }
    }

    String dominantIntensity = "---";
    if (intensities.contains("Yüksek")) {
      dominantIntensity = "Yüksek";
    } else if (intensities.contains("Orta")) {
      dominantIntensity = "Orta";
    } else if (intensities.isNotEmpty) {
      dominantIntensity = "Düşük";
    }

    return {
      'totalCalories': totalCalories,
      'totalMinutes': totalMinutes,
      'intensity': dominantIntensity,
      'hasData': snapshot.docs.any((doc) => doc.data()['isCompleted'] == true),
    };
  }

  // 6. Haftalık Grafik Verilerini Çekme (Son 7 Gün)
  Future<List<double>> getWeeklyCalories() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return List.filled(7, 0.0);

    final now = DateTime.now();
    List<double> weeklyData = List.filled(7, 0.0);
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .where('date', isGreaterThanOrEqualTo: sevenDaysAgo.toIso8601String())
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['isCompleted'] == true) {
        final date = DateTime.parse(data['date']);
        final difference = now.difference(date).inDays;
        
        if (difference >= 0 && difference < 7) {
          // 0: Bugün, 1: Dün ... 6: 7 gün önce. 
          // Grafikte soldan sağa kronolojik dizmek için 6-difference
          weeklyData[6 - difference] += (data['estimatedCalories'] as num? ?? 0).toDouble();
        }
      }
    }
    return weeklyData;
  }
}