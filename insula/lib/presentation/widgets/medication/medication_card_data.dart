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
  final bool isTaken;

  MedicationCardData({
    required this.name,
    required this.dosage,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.dosageColor,
    required this.isTaken,
  });
}
