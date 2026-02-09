import 'package:flutter/material.dart';

/// İlaç kartında gösterilecek tek bir ilacın görüntü verilerini tutar.
/// İsim, doz, saat, ikon ve renk bilgileri ile alındı mı (isTaken) bilgisini içerir.
class MedicationCardData {
  final String name;
  final String dosage;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color dosageColor;
  bool isTaken;
  final int parentIndex;
  final int doseIndex;

  MedicationCardData({
    required this.name,
    required this.dosage,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.dosageColor,
    required this.isTaken,
    required this.parentIndex,
    required this.doseIndex,
  });
}
