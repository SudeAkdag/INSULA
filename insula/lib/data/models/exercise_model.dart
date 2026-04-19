import 'package:flutter/material.dart';

class ExerciseModel {
  final String id;
  final String activityName;
  final int durationMinutes;
  final double? glucoseBefore;
  final double? glucoseAfter;
  final DateTime date;
  final bool isCompleted;
  final DateTime? startTime;
  final double userWeight;
  // ✅ EKSİK OLAN DEĞİŞKEN BURADAYDI:
  final double estimatedCalories; 
  final String intensityLevel;

  ExerciseModel({
    required this.id,
    required this.activityName,
    required this.durationMinutes,
    this.glucoseBefore,
    this.glucoseAfter,
    required this.date,
    this.isCompleted = false,
    this.startTime,
    this.userWeight = 70.0,
  })  : // ✅ Constructor içinde hesaplamaları yapıyoruz (Virgüllü double için .round() kaldırıldı)
        estimatedCalories = _calculateCaloriesStatic(activityName, durationMinutes, userWeight),
        intensityLevel = _calculateIntensityStatic(_calculateCaloriesStatic(activityName, durationMinutes, userWeight), durationMinutes);

  // ✅ HATA ÇÖZÜMÜ: localDate (UTC -> Local dönüşümü)
  DateTime get localDate => date.toLocal();

  // ✅ HATA ÇÖZÜMÜ: dayOnly (Sadece Takvim Günü)
  DateTime get dayOnly => DateTime(localDate.year, localDate.month, localDate.day);

  // ✅ activityIcon (İkon Belirleme)
  IconData get activityIcon {
    switch (activityName.toLowerCase()) {
      case "koşu":
      case "koşu (hızlı)": return Icons.directions_run;
      case "ağırlık":
      case "ağırlık antrenmanı": return Icons.fitness_center;
      case "yoga":
      case "pilates": return Icons.self_improvement;
      case "bisiklet": return Icons.directions_bike;
      case "yüzme": return Icons.pool;
      case "yürüyüş": return Icons.directions_walk;
      default: return Icons.directions_walk;
    }
  }

  // ✅ Statik Kalori Hesaplayıcı (Virgüllü sonuç için double döner)
  static double _calculateCaloriesStatic(String activity, int minutes, double weight) {
    double met;
    switch (activity.toLowerCase()) {
      case "koşu": met = 9.8; break;
      case "yürüyüş": met = 3.5; break;
      case "bisiklet": met = 7.5; break;
      case "ağırlık": met = 6.0; break;
      case "yoga": met = 2.5; break;
      default: met = 3.5;
    }
    return (met * weight * minutes) / 60.0;
  }

  // ✅ Statik Yoğunluk Hesaplayıcı
  static String _calculateIntensityStatic(double calories, int minutes) {
    if (minutes == 0) return "DÜŞÜK YOĞUNLUK";
    double calPerMin = calories / minutes;
    if (calPerMin >= 7.0) return "YÜKSEK YOĞUNLUK";
    if (calPerMin >= 4.0) return "ORTA YOĞUNLUK";
    return "DÜŞÜK YOĞUNLUK";
  }

  // Veritabanına kayıt için
  Map<String, dynamic> toMap() {
    return {
      'activityName': activityName,
      'durationMinutes': durationMinutes,
      'glucoseBefore': glucoseBefore,
      'glucoseAfter': glucoseAfter,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'userWeight': userWeight,
      'estimatedCalories': estimatedCalories, // Artik eksik değil!
      'intensityLevel': intensityLevel,
    };
  }

  // Veritabanından okumak için
  factory ExerciseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExerciseModel(
      id: id,
      activityName: map['activityName'] ?? '',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      glucoseBefore: (map['glucoseBefore'] as num?)?.toDouble(),
      glucoseAfter: (map['glucoseAfter'] as num?)?.toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']).toLocal() : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      userWeight: (map['userWeight'] as num?)?.toDouble() ?? 70.0,
    );
  }
}