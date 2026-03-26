// ignore_for_file: use_build_context_synchronously, prefer_final_fields, deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/services/water_service.dart';

class WaterTrackingScreen extends StatefulWidget {
  const WaterTrackingScreen({super.key});

  @override
  State<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends State<WaterTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  final WaterService _waterService = WaterService();

  double _currentIntake = 0;
  DateTime _selectedDate = DateTime.now();

  DateTime get _selectedDay =>
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  String get _selectedDateKey =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _loadTodayTotal();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayTotal() async {
    try {
      final total = await _waterService.getTodayTotal();
      if (mounted) setState(() => _currentIntake = total);
    } catch (_) {}
  }

  // Ayarlar Menüsü (Firestore'a hedef kaydeder)
  void _openSettingsSheet(double currentTarget) {
    final ctrl = TextEditingController(text: currentTarget.toInt().toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Ayarlar", style: AppTextStyles.h1.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Örn. 2500"),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                final v = double.tryParse(ctrl.text.trim());
                if (v != null && v > 0) {
                  await _waterService.saveWaterTarget(v); // Firebase'e yazıyor
                }
                if (mounted) Navigator.of(ctx).pop();
              },
              child: Text("Hedefi Kaydet",
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textMainDark,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              try {
                await _waterService.clearTodayEntries(_selectedDateKey);
                if (mounted) {
                  setState(() => _currentIntake = 0);
                  Navigator.of(ctx).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sıfırlama hatası: $e')));
                }
              }
            },
            icon: const Icon(Icons.refresh, color: AppColors.tertiary),
            label: Text("Bugünkü tüketimi sıfırla",
                style: AppTextStyles.body.copyWith(
                    color: AppColors.tertiary, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  Future<void> _addWater(double amount, double currentTarget) async {
    try {
      await _waterService.addEntry(amountMl: amount);
      final today = DateTime.now();
      if (_selectedDay == DateTime(today.year, today.month, today.day)) {
        setState(() {
          _currentIntake += amount;
          if (_currentIntake > currentTarget) _currentIntake = currentTarget;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Kayıt hatası: $e')));
      }
    }
  }

  void _showManualAddSheet(double currentTarget) {
    final ctrl = TextEditingController(text: '0');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Manuel Su Ekle",
              style: AppTextStyles.h1.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: "Örn. 250"),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                final v = double.tryParse(ctrl.text.trim());
                Navigator.of(ctx).pop();
                if (v != null && v > 0) _addWater(v, currentTarget);
              },
              child: Text("Ekle",
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
    return StreamBuilder<double>(
      stream: _waterService.getWaterTarget(),
      builder: (context, targetSnap) {
        final double _dailyTarget = targetSnap.data ?? 2500.0;
        double percentage = (_currentIntake / _dailyTarget).clamp(0.0, 1.0);

        final screenWidth = MediaQuery.of(context).size.width;
        final outerCircleSize = screenWidth * 0.85;
        final innerCircleSize = outerCircleSize - 20;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.textMainLight),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Su Takibi",
                style:
                    AppTextStyles.h1.copyWith(color: AppColors.textMainLight)),
            centerTitle: true,
            actions: [
              IconButton(
                icon:
                    const Icon(Icons.settings, color: AppColors.textMainLight),
                onPressed: () => _openSettingsSheet(_dailyTarget),
              ),
            ],
          ),
          body: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _waterService.getLogs(),
            builder: (context, snapshot) {
              final allLogs = snapshot.data ?? [];

              final dayLogs = allLogs.where((l) {
                return (l['date'] as String?) == _selectedDateKey;
              }).toList();

              final dayTotal = dayLogs.fold<double>(
                  0, (s, l) => s + ((l['amountMl'] as num?)?.toDouble() ?? 0));

              final today = DateTime.now();
              if (_selectedDay ==
                  DateTime(today.year, today.month, today.day)) {
                final todayTotal = dayTotal;
                if (_currentIntake != todayTotal && todayTotal > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _currentIntake = todayTotal);
                  });
                } else if (todayTotal == 0 && _currentIntake != 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _currentIntake = 0);
                  });
                }
              }

              final days = List.generate(
                14,
                (i) => DateTime(today.year, today.month, today.day - (13 - i)),
              );

              final datesWithData =
                  allLogs.map((l) => l['date'] as String? ?? '').toSet();

              return Column(
                children: [
                  _buildDatePicker(days, datesWithData),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: outerCircleSize,
                            height: outerCircleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  width: 4),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5)
                              ],
                            ),
                          ),
                          ClipOval(
                            child: SizedBox(
                              width: innerCircleSize,
                              height: innerCircleSize,
                              child: AnimatedBuilder(
                                animation: _waveAnimation,
                                builder: (_, __) => CustomPaint(
                                  painter: WavePainter(
                                    animationValue: _waveAnimation.value,
                                    percentage: _selectedDay ==
                                            DateTime(today.year, today.month,
                                                today.day)
                                        ? percentage
                                        : (dayTotal / _dailyTarget).clamp(0, 1),
                                    color: Colors.cyan.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(
                              "${((dayTotal / _dailyTarget).clamp(0, 1) * 100).toInt()}%",
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 48,
                                color: (dayTotal / _dailyTarget) > 0.5
                                    ? Colors.white
                                    : AppColors.textMainLight,
                              ),
                            ),
                            Text(
                              "${dayTotal.toInt()} / ${_dailyTarget.toInt()} ml",
                              style: AppTextStyles.body.copyWith(
                                fontSize: 16,
                                color: (dayTotal / _dailyTarget) > 0.5
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.textSecLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5))
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hızlı Ekle", style: AppTextStyles.h1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickAddButton(
                                  200, Icons.local_drink, _dailyTarget),
                              _buildQuickAddButton(
                                  350, Icons.coffee, _dailyTarget),
                              _buildQuickAddButton(
                                  500, Icons.local_cafe_outlined, _dailyTarget),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showManualAddSheet(_dailyTarget),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tertiary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 3,
                              ),
                              child: const Text("Manuel Ekle",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ]),
                  ),
                  Expanded(
                    flex: 1,
                    child: dayLogs.isEmpty
                        ? Center(
                            child: Text(
                              'Bu gün için kayıt yok',
                              style: AppTextStyles.body
                                  .copyWith(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: dayLogs.length,
                            itemBuilder: (_, i) {
                              final ml =
                                  (dayLogs[i]['amountMl'] as num?)?.toInt() ??
                                      0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(children: [
                                    Icon(Icons.water_drop,
                                        color: AppColors.secondary, size: 18),
                                    const SizedBox(width: 10),
                                    Text('$ml ml',
                                        style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMainLight)),
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(List<DateTime> days, Set<String> datesWithData) {
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
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${months[_selectedDate.month]} ${_selectedDate.year}',
            style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontSize: 12),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 60,
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
                onTap: () => setState(() => _selectedDate = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: AppColors.secondary.withOpacity(0.35),
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
                                  : AppColors.textSecLight)),
                      const SizedBox(height: 4),
                      Text('${d.day}',
                          style: AppTextStyles.h1.copyWith(
                              fontSize: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textMainLight)),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: hasData
                              ? (isSelected
                                  ? Colors.white.withOpacity(0.7)
                                  : AppColors.secondary)
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

  Widget _buildQuickAddButton(
      double amount, IconData icon, double currentTarget) {
    return InkWell(
      onTap: () => _addWater(amount, currentTarget),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          const SizedBox(height: 4),
          Text("${amount.toInt()} ml",
              style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textMainLight)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                color: AppColors.secondary, shape: BoxShape.circle),
            child: const Icon(Icons.add, size: 12, color: Colors.white),
          ),
        ]),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double percentage;
  final Color color;

  WavePainter(
      {required this.animationValue,
      required this.percentage,
      required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (percentage == 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    final waveHeight = size.height * 0.05;
    final baseHeight = size.height * (1 - percentage);
    path.moveTo(0, baseHeight);
    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
          x,
          baseHeight +
              sin((x / size.width * 2 * pi) + animationValue) * waveHeight);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter old) =>
      old.animationValue != animationValue || old.percentage != percentage;
}
