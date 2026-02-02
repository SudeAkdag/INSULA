import 'package:flutter/material.dart';

class ExerciseModel {
  final String id;
  final String activityName;
  final int durationMinutes;
  final double? glucoseBefore;
  final double? glucoseAfter;
  final DateTime date;
  final bool isCompleted; // Eklendi: Tamamlanma durumu
  final DateTime? startTime; // Eklendi: Egzersizin gerçek başlama zamanı

  ExerciseModel({
    required this.id,
    required this.activityName,
    required this.durationMinutes,
    this.glucoseBefore,
    this.glucoseAfter,
    required this.date,
    this.isCompleted = false, // Varsayılan: Tamamlanmadı
    this.startTime,
  });

  // İkon belirleme mantığı
  IconData get activityIcon {
    switch (activityName) {
      case "Koşu": return Icons.directions_run;
      case "Ağırlık": return Icons.fitness_center;
      case "Yoga": return Icons.self_improvement;
      case "Bisiklet": return Icons.directions_bike;
      case "Yüzme": return Icons.pool;
      default: return Icons.directions_walk;
    }
  }

  // Kalori hesabı
  int get estimatedCalories {
    double metValue;
    switch (activityName) {
      case "Koşu": metValue = 8.0; break;
      case "Ağırlık": metValue = 5.0; break;
      case "Bisiklet": metValue = 7.5; break;
      case "Yoga": metValue = 3.0; break;
      default: metValue = 3.5; break;
    }
    return ((metValue * 3.5 * 70) / 200 * durationMinutes).round();
  }

  String get intensityLevel {
    int calories = estimatedCalories;
    if (calories < 100) return "DÜŞÜK YOĞUNLUK";
    if (calories < 300) return "ORTA YOĞUNLUK";
    return "YÜKSEK YOĞUNLUK";
  }
}