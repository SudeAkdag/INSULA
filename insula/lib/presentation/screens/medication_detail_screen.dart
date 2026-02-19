// İlaç Detayları sayfası. Widget'lar presentation/widgets/medication_detail/ altındaki
// ayrı dosyalardan import edilir (hero kartı, kullanım takvimi kartları, notlar, tehlikeli işlemler).
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/medication_detail/medication_detail_hero_card.dart';
import '../widgets/medication_detail/medication_detail_usage_schedule_card.dart';
import '../widgets/medication_detail/medication_detail_notes_card.dart';
import '../widgets/medication_detail/medication_detail_danger_zone.dart';
import 'add_medication_screen.dart';

class MedicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationDetailScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final name = medication['name'] as String? ?? 'İlaç';
    final medicationType = medication['medicationType'] as String? ?? 'Tablet';
    final dosage = medication['dosage'] as String? ?? '';
    final frequency = medication['frequency'] as String? ?? 'Günde 1 kez';
    final doseTimes = medication['doseTimes'] as List<TimeOfDay>? ?? [];
    final doseAmounts = medication['doseAmounts'] as List<String>? ?? [];
    final doseUsageTimes = medication['doseUsageTimes'] as List<String>? ?? [];
    final doseConditions = medication['doseConditions'] as List<String>? ?? [];
    final notes = medication['notes'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accentTeal),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'İlaç Detayları',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute<Map<String, dynamic>>(
                  builder: (context) => AddMedicationScreen(medication: medication),
                ),
              );
              if (result != null && context.mounted) {
                Navigator.pop(context, result); // Güncellenmiş veriyi geri gönder
              }
            },
            child: Text(
              'Düzenle',
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MedicationDetailHeroCard(
            name: name,
            medicationType: medicationType,
            dosage: dosage,
            frequency: frequency,
          ),
          _buildUsageScheduleSection(
            doseTimes: doseTimes,
            doseAmounts: doseAmounts,
            doseUsageTimes: doseUsageTimes,
            doseConditions: doseConditions,
          ),
          MedicationDetailNotesCard(notes: notes),
          MedicationDetailDangerZone(
            medicationName: name,
            onArchive: () {
              // TODO: İlacı arşivle
            },
            onDelete: () {
              Navigator.pop(context, true); // true = deleted
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsageScheduleSection({
    required List<TimeOfDay> doseTimes,
    required List<String> doseAmounts,
    required List<String> doseUsageTimes,
    required List<String> doseConditions,
  }) {
    final usageTimeColors = {
      'Sabah': AppColors.accentTeal,
      'Öğle': AppColors.primary,
      'Akşam': const Color(0xFFF2C12E),
      'Diğer': AppColors.accentTeal,
    };
    final usageTimeIcons = {
      'Sabah': Icons.light_mode,
      'Öğle': Icons.wb_sunny,
      'Akşam': Icons.dark_mode,
      'Diğer': Icons.schedule,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kullanım Takvimi',
            style: AppTextStyles.h1.copyWith(
              fontSize: 18,
              color: AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(doseTimes.length, (i) {
            final usageTime = i < doseUsageTimes.length
                ? doseUsageTimes[i]
                : 'Diğer';
            String timeStr;
            if (i < doseTimes.length) {
              final h = doseTimes[i].hour;
              final m = doseTimes[i].minute;
              final isPM = h >= 12;
              final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
              timeStr = '${displayHour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} ${isPM ? 'PM' : 'AM'}';
            } else {
              timeStr = 'İhtiyaç Halinde';
            }
            final amountText = i < doseAmounts.length
                ? '${doseAmounts[i]} Dozaj'
                : 'Belirtilen Durumlarda';
            final condition = i < doseConditions.length
                ? doseConditions[i].toUpperCase().replaceAll(' ', '_')
                : 'DOKTOR_KONTROLÜNDE';
            final color = usageTimeColors[usageTime] ?? AppColors.accentTeal;
            final icon = usageTimeIcons[usageTime] ?? Icons.schedule;

            return MedicationDetailUsageScheduleCard(
              usageTime: usageTime,
              timeStr: timeStr,
              amountText: amountText,
              condition: condition,
              color: color,
              icon: icon,
            );
          }),
        ],
      ),
    );
  }
}
