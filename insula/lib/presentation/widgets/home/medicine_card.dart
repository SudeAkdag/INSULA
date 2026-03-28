// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/medication_service.dart';
import '../../screens/medication_screen.dart';
import '../../../core/theme/nutrient_colors.dart';

class MedicineCard extends StatefulWidget {
  const MedicineCard({super.key});

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  final MedicationService _service = MedicationService();
  StreamSubscription? _sub;
  Timer? _timer;

  List<_DoseEntry> _allDoses = [];

  String _nextDoseName = '';
  String _nextDoseDetail = '';
  String _countdown = '';

  // Zaman bazlı ilerleme barı için eklendi (0.0 ile 1.0 arası)
  double _timeProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _listenMedications();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _recalculate();
    });
  }

  void _listenMedications() {
    _sub?.cancel();
    _sub = _service.getMedications().listen((meds) {
      if (!mounted) return;
      final doses = <_DoseEntry>[];

      for (final med in meds) {
        final doseTimes = med['doseTimes'] as List<TimeOfDay>?;
        final doseAmounts = med['doseAmounts'] as List<String>?;
        final name = med['name'] as String? ?? '';

        if (doseTimes == null) continue;

        for (int i = 0; i < doseTimes.length; i++) {
          final dosage = doseAmounts != null && i < doseAmounts.length
              ? doseAmounts[i]
              : '';
          doses.add(_DoseEntry(
            name: name,
            dosage: dosage,
            time: doseTimes[i],
          ));
        }
      }

      doses.sort((a, b) {
        final aMin = a.time.hour * 60 + a.time.minute;
        final bMin = b.time.hour * 60 + b.time.minute;
        return aMin.compareTo(bMin);
      });

      _allDoses = doses;
      _recalculate();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _recalculate() {
    if (_allDoses.isEmpty) {
      if (mounted) {
        setState(() {
          _nextDoseName = '';
          _nextDoseDetail = '';
          _countdown = '';
          _timeProgress = 0.0;
        });
      }
      return;
    }

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    _DoseEntry? next;
    for (final d in _allDoses) {
      final dMin = d.time.hour * 60 + d.time.minute;
      if (dMin > nowMinutes) {
        next = d;
        break;
      }
    }

    next ??= _allDoses.first;

    DateTime target = DateTime(
        now.year, now.month, now.day, next.time.hour, next.time.minute);
    if (!target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }

    // --- ZAMANA GÖRE İLERLEME HESAPLAMASI ---
    DateTime? previousTarget;
    // Geçmişteki en son dozu bul
    for (int i = _allDoses.length - 1; i >= 0; i--) {
      final dMin = _allDoses[i].time.hour * 60 + _allDoses[i].time.minute;
      if (dMin <= nowMinutes) {
        previousTarget = DateTime(now.year, now.month, now.day,
            _allDoses[i].time.hour, _allDoses[i].time.minute);
        break;
      }
    }
    // Bugün hiç doz saati geçmediyse dünkü son dozu başlangıç kabul et
    if (previousTarget == null) {
      final lastDose = _allDoses.last;
      previousTarget = DateTime(now.year, now.month, now.day - 1,
          lastDose.time.hour, lastDose.time.minute);
    }

    double currentProgress = 0.0;
    final totalSeconds = target.difference(previousTarget).inSeconds;
    final elapsedSeconds = now.difference(previousTarget).inSeconds;

    if (totalSeconds > 0) {
      currentProgress = elapsedSeconds / totalSeconds;
      currentProgress = currentProgress.clamp(
          0.0, 1.0); // Değerin 0 ile 1 arasında kalmasını garanti eder
    }
    // ----------------------------------------

    final diff = target.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    final s = diff.inSeconds.remainder(60);

    String countdown;
    if (h > 0) {
      countdown = '${h}sa ${m}dk ${s}sn kaldı';
    } else if (m > 0) {
      countdown = '${m}dk ${s}sn kaldı';
    } else {
      countdown = '${s}sn kaldı';
    }

    if (mounted) {
      setState(() {
        _nextDoseName = next!.name;
        _nextDoseDetail = next.dosage;
        _countdown = countdown;
        _timeProgress = currentProgress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNext = _nextDoseName.isNotEmpty;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MedicationScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(24),
          // 1. SORUNUN ÇÖZÜMÜ: Border rengine softluk (.withOpacity) katıldı
          border:
              Border.all(color: NutrientColors.fat.withOpacity(0.3), width: 3),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.05), // Gölge de biraz yumuşatıldı
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: NutrientColors.fat, size: 20),
                const SizedBox(width: 8),
                Text(
                  'İLAÇ TAKİBİ',
                  style: AppTextStyles.h1
                      .copyWith(color: NutrientColors.fat, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasNext ? _nextDoseName : 'İlaç bulunamadı',
                        style: AppTextStyles.h1.copyWith(
                          color: NutrientColors.fat,
                          fontSize:
                              12, // İlaç adı fontu karta daha uygun boyuta çekildi
                        ),
                      ),
                      if (hasNext && _nextDoseDetail.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _nextDoseDetail,
                          style: AppTextStyles.body.copyWith(
                            color: NutrientColors.fat.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sıradaki ilaca kalan süre:',
                      style: AppTextStyles.label.copyWith(
                        color: NutrientColors.fat.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _countdown.isNotEmpty ? _countdown : '--',
                      style: AppTextStyles.label.copyWith(
                        color: NutrientColors.fat,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _timeProgress,
                    backgroundColor: NutrientColors.fat.withOpacity(0.15),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(NutrientColors.fat),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DoseEntry {
  final String name;
  final String dosage;
  final TimeOfDay time;

  const _DoseEntry({
    required this.name,
    required this.dosage,
    required this.time,
  });
}
