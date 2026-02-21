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


  Map<String, dynamic> toMap() {
    return {
      'activityName': activityName,
      'durationMinutes': durationMinutes,
      'glucoseBefore': glucoseBefore,
      'glucoseAfter': glucoseAfter,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'startTime': startTime?.toIso8601String(),
      'estimatedCalories': estimatedCalories,
      'intensityLevel': intensityLevel,
    };
  }

  factory ExerciseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExerciseModel(
      id: id,
      activityName: map['activityName'] ?? '',
      // num kullanımı int ve double karmaşasını önler
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      glucoseBefore: (map['glucoseBefore'] as num?)?.toDouble(),
      glucoseAfter: (map['glucoseAfter'] as num?)?.toDouble(),
      // Tarih verisi string olarak saklandığı için parse edilir
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
    );
  }
}