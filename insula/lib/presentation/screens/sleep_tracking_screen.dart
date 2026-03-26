// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/sleep_service.dart';
import '../../core/theme/nutrient_colors.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  final SleepService _sleepService = SleepService();
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();
  bool _isInitialLoad = true;

  DateTime get _selectedDay =>
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  String get _selectedDateKey =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Duration get _sleepDuration {
    if (_bedTime == null || _wakeTime == null) return Duration.zero;
    final bedMins = _bedTime!.hour * 60 + _bedTime!.minute;
    final wakeMins = _wakeTime!.hour * 60 + _wakeTime!.minute;
    int diff = wakeMins - bedMins;
    if (diff <= 0) diff += 24 * 60;
    return Duration(minutes: diff);
  }

  String get _formattedSleepDuration {
    if (_bedTime == null || _wakeTime == null) return '--sa --dk';
    final h = _sleepDuration.inHours;
    final m = _sleepDuration.inMinutes.remainder(60);
    return m == 0 ? '${h}sa' : '${h}sa ${m}dk';
  }

  Future<void> _pickTime({required bool isBedTime}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedTime
          ? (_bedTime ?? const TimeOfDay(hour: 23, minute: 0))
          : (_wakeTime ?? const TimeOfDay(hour: 7, minute: 0)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: NutrientColors.fat,
            surface: AppColors.surfaceDark,
            onSurface: Colors.white,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) {
      setState(() => isBedTime ? _bedTime = picked : _wakeTime = picked);
    }
  }

  String _fmt(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveEntry(String? docId) async {
    if (_bedTime == null || _wakeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen yatma ve uyanma saatlerini seçin ⚠️')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (docId != null) {
        await _sleepService.updateEntry(
          docId: docId,
          bedTime: _fmt(_bedTime),
          wakeTime: _fmt(_wakeTime),
          durationMinutes: _sleepDuration.inMinutes,
        );
      } else {
        await _sleepService.addEntry(
          bedTime: _fmt(_bedTime),
          wakeTime: _fmt(_wakeTime),
          durationMinutes: _sleepDuration.inMinutes,
          date: _selectedDateKey,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(docId != null
                  ? 'Uyku verisi güncellendi 🔄'
                  : 'Uyku verisi kaydedildi ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayıt/Güncelleme hatası: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Ayarlar Menüsü (Firestore'a yazar)
  void _openSettingsSheet(int currentTarget) {
    final ctrl = TextEditingController(text: currentTarget.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Uyku Hedefi",
              style: AppTextStyles.h1
                  .copyWith(fontSize: 20, color: AppColors.textMainDark)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: NutrientColors.fat, width: 2),
              ),
              hintText: "Örn. 8",
              hintStyle: const TextStyle(color: Colors.white54),
              labelText: "Hedeflenen Uyku (Saat)",
              labelStyle: TextStyle(color: NutrientColors.fat.withOpacity(0.8)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: NutrientColors.fat,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                final v = int.tryParse(ctrl.text.trim());
                if (v != null && v > 0) {
                  // Firestore'a kaydet
                  await _sleepService.saveSleepTarget(v);
                }
                if (mounted) Navigator.of(ctx).pop();
              },
              child: Text("Kaydet",
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textMainDark,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sayfanın en dışında hedefi dinleyen StreamBuilder
    return StreamBuilder<int>(
      stream: _sleepService.getSleepTarget(),
      builder: (context, targetSnap) {
        final targetHours = targetSnap.data ?? 8;

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.textMainDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text("Uyku Takibi",
                style:
                    AppTextStyles.h1.copyWith(color: AppColors.textMainDark)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.textMainDark),
                onPressed: () => _openSettingsSheet(targetHours),
              ),
            ],
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _sleepService.getLogs(),
            builder: (context, snapshot) {
              final allLogs = snapshot.data ?? [];
              final dayLogs = allLogs
                  .where((l) => (l['date'] as String?) == _selectedDateKey)
                  .toList();

              final existingLog = dayLogs.isNotEmpty ? dayLogs.first : null;
              final existingDocId = existingLog?['id'] as String?;
              final isUpdating = existingDocId != null;

              if (existingLog != null && _isInitialLoad) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      final bedParts =
                          (existingLog['bedTime'] as String).split(':');
                      final wakeParts =
                          (existingLog['wakeTime'] as String).split(':');
                      _bedTime = TimeOfDay(
                          hour: int.parse(bedParts[0]),
                          minute: int.parse(bedParts[1]));
                      _wakeTime = TimeOfDay(
                          hour: int.parse(wakeParts[0]),
                          minute: int.parse(wakeParts[1]));
                      _isInitialLoad = false;
                    });
                  }
                });
              } else if (existingLog == null && _isInitialLoad) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _bedTime = null;
                      _wakeTime = null;
                      _isInitialLoad = false;
                    });
                  }
                });
              }

              final today = DateTime.now();
              final days = List.generate(
                14,
                (i) => DateTime(today.year, today.month, today.day - (13 - i)),
              );

              final datesWithData =
                  allLogs.map((l) => l['date'] as String? ?? '').toSet();

              return SafeArea(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    _buildDatePicker(days, datesWithData, allLogs),
                    const SizedBox(height: 16),

                    // Uyku Süresi Dairesi
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(colors: [
                            NutrientColors.fat.withOpacity(0.9),
                            AppColors.tertiary.withOpacity(0.9),
                            NutrientColors.fat.withOpacity(0.9),
                          ]),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              shape: BoxShape.circle),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Toplam Uyku",
                                  style: AppTextStyles.body
                                      .copyWith(color: AppColors.textSecDark)),
                              const SizedBox(height: 8),
                              Text(
                                  isUpdating
                                      ? "${(existingLog?['durationMinutes'] as int) ~/ 60}sa ${(existingLog?['durationMinutes'] as int) % 60}dk"
                                      : _formattedSleepDuration,
                                  style: AppTextStyles.h1.copyWith(
                                      color: AppColors.textMainDark,
                                      fontSize: 30)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: NutrientColors.fat.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Hedef: ${targetHours}sa",
                                  style: AppTextStyles.label.copyWith(
                                      color: NutrientColors.fat,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Giriş Kartı
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Manuel Düzenleme",
                                  style: AppTextStyles.h1.copyWith(
                                      color: AppColors.textMainDark,
                                      fontSize: 18)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text("MANUEL",
                                    style: AppTextStyles.label
                                        .copyWith(color: NutrientColors.fat)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(
                              child: _TimePickerTile(
                                  label: "Yatma Saati",
                                  timeText: _fmt(_bedTime),
                                  onTap: () => _pickTime(isBedTime: true)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _TimePickerTile(
                                  label: "Uyanma Saati",
                                  timeText: _fmt(_wakeTime),
                                  onTap: () => _pickTime(isBedTime: false)),
                            ),
                          ]),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NutrientColors.fat,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _isSaving
                                  ? null
                                  : () => _saveEntry(existingDocId),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Text(isUpdating ? "Güncelle" : "Kaydet",
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.textMainDark,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tekil Gün Kaydı
                    Text("Günün Kaydı",
                        style: AppTextStyles.h1.copyWith(
                            color: AppColors.textMainDark, fontSize: 18)),
                    const SizedBox(height: 12),

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        allLogs.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (existingLog == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Bu gün için kayıt yok",
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textSecDark)),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.06)),
                          ),
                          child: Row(children: [
                            Icon(Icons.bedtime,
                                color: NutrientColors.fat, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${existingLog['bedTime']} → ${existingLog['wakeTime']}",
                                        style: AppTextStyles.body.copyWith(
                                            color: AppColors.textMainDark,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        "${(existingLog['durationMinutes'] as int) ~/ 60}sa ${(existingLog['durationMinutes'] as int) % 60}dk",
                                        style: AppTextStyles.label.copyWith(
                                            color: AppColors.textSecDark)),
                                  ]),
                            ),
                          ]),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(List<DateTime> days, Set<String> datesWithData,
      List<Map<String, dynamic>> allLogs) {
    const weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    const months = [
      '',
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara'
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${months[_selectedDate.month]} ${_selectedDate.year}',
            style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.bold,
                color: NutrientColors.fat,
                fontSize: 12),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 68,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final d = days[i];
              final dKey =
                  '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              final isSelected =
                  DateTime(d.year, d.month, d.day) == _selectedDay;
              final hasData = datesWithData.contains(dKey);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = d;
                    _isInitialLoad = true;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? NutrientColors.fat
                        : AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: NutrientColors.fat.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(weekDays[(d.weekday - 1) % 7],
                          style: AppTextStyles.label.copyWith(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.textSecDark)),
                      const SizedBox(height: 4),
                      Text('${d.day}',
                          style: AppTextStyles.h1.copyWith(
                              fontSize: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMainDark)),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasData
                              ? (isSelected
                                  ? Colors.white.withOpacity(0.7)
                                  : NutrientColors.fat)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  final String label;
  final String timeText;
  final VoidCallback onTap;

  const _TimePickerTile(
      {required this.label, required this.timeText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTextStyles.label.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeText,
                  style: AppTextStyles.h1
                      .copyWith(color: Colors.white, fontSize: 18)),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.white60),
            ],
          ),
        ]),
      ),
    );
  }
}
