// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/data/models/glucose_model.dart';
import 'package:insula/data/services/glucose_service.dart';
import 'package:insula/presentation/widgets/home/bottom_sheets/glucose_entry_bottom_sheet.dart';

/// Kan şekeri detay sayfası - geçmiş ölçümler, grafik, istatistikler.
/// targetMin/Max çağıran sayfadan geçirilir (Provider yeni route'ta erişilemez).
class GlucoseDetailScreen extends StatefulWidget {
  const GlucoseDetailScreen({
    super.key,
    this.targetMin = 70,
    this.targetMax = 140,
  });

  final int targetMin;
  final int targetMax;

  @override
  State<GlucoseDetailScreen> createState() => _GlucoseDetailScreenState();
}

/// Tüm context etiketleri
const _kContextLabels = [
  'Açlık',
  'Yemek öncesi',
  'Yemek sonrası',
  'Egzersiz öncesi',
  'Egzersiz sonrası',
  'Genel',
];

class _GlucoseDetailScreenState extends State<GlucoseDetailScreen> {
  final GlucoseService _glucoseService = GlucoseService();
  List<GlucoseReading> _readings = [];
  bool _isLoading = true;
  String? _errorMessage;

  // ── Filtre state ──────────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();  // seçili gün
  String? _selectedContext;                  // null = "Tümü"

  // ── Yardımcı: Seçili tarihin günü ────────────────────────────────
  DateTime get _selectedDay =>
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

  // ── Filtrelenmiş ölçümler ─────────────────────────────────────────
  List<GlucoseReading> get _filtered {
    return _readings.where((r) {
      final rDay =
          DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
      final dayMatch = rDay == _selectedDay;
      final ctxRaw =
          r.context.trim().isEmpty ? 'Genel' : r.context.trim();
      final ctxMatch =
          _selectedContext == null || ctxRaw == _selectedContext;
      return dayMatch && ctxMatch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _glucoseService.getGlucoseReadings(limit: 300);
      if (mounted) {
        setState(() {
          _readings = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Veriler yüklenemedi';
          _isLoading = false;
        });
      }
    }
  }

  void _onAddReading() {
    showGlucoseEntryBottomSheet(
      context,
      onSaved: () => _loadReadings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetMin = widget.targetMin;
    final targetMax = widget.targetMax;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Kan Şekeri Detayları',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReadings,
        color: AppColors.secondary,
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.secondary),
              )
            : _errorMessage != null
                ? _buildError()
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ── Yapışkan başlık: tarih picker + chip ──
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        floating: false,
                        backgroundColor: AppColors.backgroundLight,
                        expandedHeight: 0,
                        toolbarHeight: 0,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(150),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDatePicker(),
                              _buildContextChips(),
                            ],
                          ),
                        ),
                      ),
                      // ── İçerik ─────────────────────────────────
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildSummaryCard(targetMin, targetMax),
                            const SizedBox(height: 24),
                            _buildChartSection(targetMin, targetMax),
                            const SizedBox(height: 24),
                            _buildReadingsList(targetMin, targetMax),
                          ]),
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddReading,
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add),
        label: const Text('Ölçüm Ekle'),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // TAKVIM — yatay kaydırılabilir 14 günlük seçici
  // ──────────────────────────────────────────────────────────────────
  Widget _buildDatePicker() {
    final today = DateTime.now();
    // Son 14 gün (en yeni sağda değil, solda — reversed)
    final days = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day - (13 - i)),
    );

    const weekDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];

    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ay / yıl başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${months[_selectedDate.month]} ${_selectedDate.year}',
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 62,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: days.length,
              itemBuilder: (context, i) {
                final d = days[i];
                final isSelected = DateTime(d.year, d.month, d.day) ==
                    _selectedDay;
                final hasData = _readings.any((r) {
                  final rd = DateTime(
                      r.timestamp.year, r.timestamp.month, r.timestamp.day);
                  return rd == DateTime(d.year, d.month, d.day);
                });

                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedDate = d;
                    _selectedContext = null; // chip sıfırla
                  }),
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
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekDays[(d.weekday - 1) % 7],
                          style: AppTextStyles.label.copyWith(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textSecLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${d.day}',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 16,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textMainLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Veri noktası göstergesi
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
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // CONTEXT CHIP'LERİ
  // ──────────────────────────────────────────────────────────────────
  Widget _buildContextChips() {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            // "Tümü" chip
            _buildChip(
              label: 'Tümü',
              isSelected: _selectedContext == null,
              onTap: () => setState(() => _selectedContext = null),
              icon: Icons.apps_rounded,
            ),
            const SizedBox(width: 6),
            ..._kContextLabels.map((ctx) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildChip(
                  label: ctx,
                  isSelected: _selectedContext == ctx,
                  onTap: () => setState(() =>
                      _selectedContext =
                          _selectedContext == ctx ? null : ctx),
                  icon: _iconForContext(ctx),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : AppColors.secondary.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForContext(String ctx) {
    switch (ctx) {
      case 'Açlık':
        return Icons.no_food_rounded;
      case 'Yemek öncesi':
        return Icons.restaurant_menu_rounded;
      case 'Yemek sonrası':
        return Icons.restaurant_rounded;
      case 'Egzersiz öncesi':
        return Icons.directions_run_rounded;
      case 'Egzersiz sonrası':
        return Icons.fitness_center_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // HATA
  // ──────────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.tertiary),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Bir hata oluştu',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecLight),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReadings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // ÖZET KARTI — filtrelenmiş verileri kullanır
  // ──────────────────────────────────────────────────────────────────
  Widget _buildSummaryCard(int targetMin, int targetMax) {
    final data = _filtered;

    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.monitor_heart_outlined,
                size: 48, color: AppColors.textSecLight),
            const SizedBox(height: 12),
            Text(
              'Bu gün için ölçüm bulunamadı',
              style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecLight, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedContext != null
                  ? '"$_selectedContext" bağlamında kayıt yok'
                  : 'Farklı bir tarih seçin veya ölçüm ekleyin',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecLight, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final latest = data.first;
    final status =
        GlucoseReading.statusFromRange(latest.value, targetMin, targetMax);
    final inRangeCount =
        data.where((r) => r.value >= targetMin && r.value <= targetMax).length;
    final inRangePercent =
        data.isNotEmpty ? ((inRangeCount / data.length) * 100).round() : 0;
    final avg = data.isEmpty
        ? 0
        : (data.fold<int>(0, (s, r) => s + r.value) / data.length).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Son Ölçüm',
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecLight,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${latest.value}',
                        style: AppTextStyles.glucoseValue
                            .copyWith(fontSize: 36),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'mg/dL',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecLight, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Ortalama', '$avg', 'mg/dL'),
              _buildStatItem('Hedefte', '%$inRangePercent', ''),
              _buildStatItem('Hedef', '$targetMin-$targetMax', ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    if (status == 'Düşük') {
      color = Colors.orange.shade700;
    } else if (status == 'Yüksek') {
      color = Colors.red.shade700;
    } else {
      color = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: AppTextStyles.label.copyWith(
            color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.label
              .copyWith(fontSize: 11, color: AppColors.textSecLight),
        ),
        const SizedBox(height: 4),
        Text(
          value + (unit.isNotEmpty ? ' $unit' : ''),
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // GRAFİK — filtrelenmiş verileri kullanır
  // ──────────────────────────────────────────────────────────────────
  Widget _buildChartSection(int targetMin, int targetMax) {
    final data = _filtered;
    if (data.length < 2) return const SizedBox.shrink();

    final recent = data.take(14).toList().reversed.toList();
    final values = recent.map((r) => r.value.toDouble()).toList();
    final maxVal =
        values.reduce((a, b) => a > b ? a : b).clamp(100.0, 400.0);
    final minVal = values.reduce((a, b) => a < b ? a : b).clamp(40.0, 100.0);
    final chartMax = (maxVal + 30).clamp(120.0, 450.0);
    final chartMin = (minVal - 20).clamp(30.0, 80.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son ${recent.length} Ölçüm',
                style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              if (_selectedContext != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedContext!,
                    style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.asMap().entries.map((entry) {
                final v = entry.value;
                final h =
                    ((v - chartMin) / (chartMax - chartMin)).clamp(0.1, 1.0);
                final inRange = v >= targetMin && v <= targetMax;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: '${v.toInt()} mg/dL',
                          child: Container(
                            height: 120 * h,
                            decoration: BoxDecoration(
                              color: inRange
                                  ? AppColors.secondary
                                  : (v < targetMin
                                      ? Colors.orange
                                      : Colors.red.shade400),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // ÖLÇÜM GEÇMİŞİ — filtrelenmiş verileri kullanır
  // ──────────────────────────────────────────────────────────────────
  Widget _buildReadingsList(int targetMin, int targetMax) {
    final data = _filtered;
    final grouped = _groupReadingsByContext(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ölçüm Geçmişi',
            style: AppTextStyles.h1.copyWith(fontSize: 18)),
        const SizedBox(height: 12),
        if (data.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              border: Border.all(color: AppColors.backgroundLight),
            ),
            child: Text(
              'Bu tarih ve filtre için kayıt bulunamadı',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecLight),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grouped.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final g = grouped[i];
              return _DayGroup(
                title: g.context,
                readings: g.readings,
                targetMin: targetMin,
                targetMax: targetMax,
              );
            },
          ),
      ],
    );
  }

  List<_ContextGroupedReadings> _groupReadingsByContext(
      List<GlucoseReading> readings) {
    final Map<String, List<GlucoseReading>> map = {};
    for (final r in readings) {
      final ctx = r.context.trim().isEmpty ? 'Genel' : r.context.trim();
      map.putIfAbsent(ctx, () => []);
      map[ctx]!.add(r);
    }

    const contextOrder = [
      'Açlık',
      'Yemek öncesi',
      'Yemek sonrası',
      'Egzersiz öncesi',
      'Egzersiz sonrası',
      'Genel',
    ];

    final sorted = map.keys.toList()
      ..sort((a, b) {
        final ia = contextOrder.indexOf(a);
        final ib = contextOrder.indexOf(b);
        if (ia == -1 && ib == -1) return a.compareTo(b);
        if (ia == -1) return 1;
        if (ib == -1) return -1;
        return ia.compareTo(ib);
      });

    return sorted.map((ctx) {
      final list = map[ctx]!
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return _ContextGroupedReadings(context: ctx, readings: list);
    }).toList();
  }
}

// ─── Veri modelleri ───────────────────────────────────────────────────────────

class _ContextGroupedReadings {
  final String context;
  final List<GlucoseReading> readings;
  _ContextGroupedReadings({required this.context, required this.readings});
}

// ─── Widget'lar ───────────────────────────────────────────────────────────────

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.title,
    required this.readings,
    required this.targetMin,
    required this.targetMax,
  });

  final String title;
  final List<GlucoseReading> readings;
  final int targetMin;
  final int targetMax;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContextHeader(label: title),
          const SizedBox(height: 10),
          ...readings.map((r) {
            final status = GlucoseReading.statusFromRange(
                r.value, targetMin, targetMax);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child:
                  _ReadingTile(reading: r, status: status, showContext: false),
            );
          }),
        ],
      ),
    );
  }
}

class _ContextHeader extends StatelessWidget {
  const _ContextHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final GlucoseReading reading;
  final String status;
  final bool showContext;

  const _ReadingTile({
    required this.reading,
    required this.status,
    this.showContext = true,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status == 'Düşük') {
      statusColor = Colors.orange.shade700;
    } else if (status == 'Yüksek') {
      statusColor = Colors.red.shade700;
    } else {
      statusColor = Colors.green.shade700;
    }

    final date = reading.timestamp;
    final now = DateTime.now();
    String dateStr;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      dateStr =
          'Bugün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      final yesterday = now.subtract(const Duration(days: 1));
      if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        dateStr =
            'Dün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        dateStr =
            '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(color: AppColors.backgroundLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${reading.value} mg/dL',
                    style: AppTextStyles.h1.copyWith(fontSize: 20)),
                Text(
                  showContext
                      ? '${reading.context} • $dateStr'
                      : dateStr,
                  style: AppTextStyles.label.copyWith(
                      fontSize: 12, color: AppColors.textSecLight),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: AppTextStyles.label.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
