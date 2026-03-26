// ignore_for_file: deprecated_member_use
/*
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/medication_service.dart';
import '../../screens/medication_screen.dart';

class MedicineCard extends StatefulWidget {
  const MedicineCard({super.key});

  @override
  State<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<MedicineCard> {
  final MedicationService _service = MedicationService();
  StreamSubscription? _sub;
  Timer? _timer;

  List<Map<String, dynamic>> _medications = [];
  String _nextDoseName = '';
  String _nextDoseDetail = '';
  String _countdown = '';
  int _totalDoses = 0;
  int _takenDoses = 0;

  @override
  void initState() {
    super.initState();
    _subscribeMedications();
    // Geri sayımı her saniye güncelle
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _recalculate();
    });
  }

  void _subscribeMedications() {
    _sub?.cancel();
    final uid = _service.getCurrentUserId();
    if (uid == null) return;
    _sub = _service.getMedicationsStream(uid).listen((meds) {
      if (mounted) {
        _medications = meds;
        _recalculate();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _recalculate() {
    final now = DateTime.now();
    int total = 0;
    int taken = 0;
    TimeOfDay? nextTime;
    String nextName = '';
    String nextDetail = '';

    for (final med in _medications) {
      final doseTimes = med['doseTimes'] as List<TimeOfDay>?;
      final flags = med['takenFlags'] as List?;
      final amounts = med['doseAmounts'] as List<String>?;
      final name = med['name'] as String? ?? '';

      if (doseTimes == null) continue;

      for (int i = 0; i < doseTimes.length; i++) {
        total++;
        final isTaken =
            flags != null && i < flags.length ? flags[i] == true : false;
        if (isTaken) {
          taken++;
        } else {
          // En yakın alınmamış saat
          final t = doseTimes[i];
          if (nextTime == null ||
              t.hour < nextTime.hour ||
              (t.hour == nextTime.hour && t.minute < nextTime.minute)) {
            nextTime = t;
            nextName = name;
            nextDetail = amounts != null && i < amounts.length
                ? amounts[i]
                : '';
          }
        }
      }
    }

    String countdown = '';
    if (nextTime != null) {
      final nextDt = DateTime(
          now.year, now.month, now.day, nextTime.hour, nextTime.minute);
      var diff = nextDt.difference(now);
      if (diff.isNegative) diff += const Duration(days: 1);
      final h = diff.inHours;
      final m = diff.inMinutes.remainder(60);
      final s = diff.inSeconds.remainder(60);
      if (h > 0) {
        countdown = '${h}sa ${m}dk kaldı';
      } else if (m > 0) {
        countdown = '${m}dk ${s}sn kaldı';
      } else {
        countdown = '${s}sn kaldı';
      }
    }

    if (mounted) {
      setState(() {
        _totalDoses = total;
        _takenDoses = taken;
        _countdown = countdown;
        _nextDoseName = nextName;
        _nextDoseDetail = nextDetail;
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE74C3C),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE74C3C).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            // Dekoratif daire
            Positioned(
              right: -24,
              bottom: -24,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık satırı + geri sayım
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "İlaç Takibi",
                          style: AppTextStyles.h1
                              .copyWith(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                    if (_countdown.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _countdown,
                              style: AppTextStyles.label
                                  .copyWith(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sonraki ilaç bilgisi
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasNext ? _nextDoseName : 'Tüm ilaçlar alındı 🎉',
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          if (hasNext && _nextDoseDetail.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _nextDoseDetail,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right,
                          color: Colors.white, size: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Footer – Toplam / Alınan özeti
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(
                          Icons.medication_liquid_outlined,
                          'Toplam',
                          '$_totalDoses ilaç'),
                      Container(width: 1, height: 28,
                          color: Colors.white.withOpacity(0.3)),
                      _buildStat(
                          Icons.check_circle_outline,
                          'Alınan',
                          '$_takenDoses ilaç'),
                      Container(width: 1, height: 28,
                          color: Colors.white.withOpacity(0.3)),
                      _buildStat(
                          Icons.pending_outlined,
                          'Kalan',
                          '${_totalDoses - _takenDoses} ilaç'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.85), size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
*/
