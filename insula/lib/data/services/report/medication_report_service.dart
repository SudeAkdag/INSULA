// İlaç uyumu raporu veri servisi.
// Firestore'dan ilaç verilerini çekip MedicationCompliance olarak döndürür.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';

class MedicationReportService {
  MedicationReportService._();

  /// Belirtilen kullanıcı için ilaç uyum verilerini yükler.
  static Future<MedicationCompliance> loadMedicationData({
    required String uid,
  }) async {
    final fs = FirebaseFirestore.instance;

    final medicationsSnap =
        await fs.collection('users').doc(uid).collection('medications').get();

    int totalDoses = 0, takenDoses = 0;
    for (final doc in medicationsSnap.docs) {
      final flags =
          ((doc.data() as Map)['takenFlags'] as List?)?.cast<bool>() ?? [];
      totalDoses += flags.length;
      takenDoses += flags.where((f) => f).length;
    }

    return MedicationCompliance(
      totalDoses: totalDoses,
      takenDoses: takenDoses,
      complianceRate: totalDoses == 0 ? 0 : takenDoses / totalDoses * 100,
    );
  }
}
