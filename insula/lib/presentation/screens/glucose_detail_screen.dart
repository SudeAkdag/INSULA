// ignore_for_file: deprecated_member_use

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

class _GlucoseDetailScreenState extends State<GlucoseDetailScreen> {
  final GlucoseService _glucoseService = GlucoseService();
  List<GlucoseReading> _readings = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      final list = await _glucoseService.getGlucoseReadings(limit: 100);
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
                child: CircularProgressIndicator(color: AppColors.secondary),
              )
            : _errorMessage != null
                ? _buildError()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(targetMin, targetMax),
                        const SizedBox(height: 24),
                        _buildChartSection(targetMin, targetMax),
                        const SizedBox(height: 24),
                        _buildReadingsList(targetMin, targetMax),
                        const SizedBox(height: 80),
                      ],
                    ),
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

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.tertiary,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Bir hata oluştu',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecLight),
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

  Widget _buildSummaryCard(int targetMin, int targetMax) {
    if (_readings.isEmpty) {
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
            Icon(
              Icons.monitor_heart_outlined,
              size: 48,
              color: AppColors.textSecLight,
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz ölçüm eklenmemiş',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'FAB ile veya üstteki + ile ölçüm ekleyebilirsiniz',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecLight,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final latest = _readings.first;
    final status =
        GlucoseReading.statusFromRange(latest.value, targetMin, targetMax);
    final inRangeCount = _readings
        .where((r) => r.value >= targetMin && r.value <= targetMax)
        .length;
    final inRangePercent = (_readings.isNotEmpty)
        ? ((inRangeCount / _readings.length) * 100).round()
        : 0;
    final avg = _readings.isEmpty
        ? 0
        : (_readings.fold<int>(0, (s, r) => s + r.value) / _readings.length)
            .round();

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
                  Text(
                    'Son Ölçüm',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${latest.value}',
                        style:
                            AppTextStyles.glucoseValue.copyWith(fontSize: 36),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'mg/dL',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecLight,
                          fontSize: 14,
                        ),
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
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            color: AppColors.textSecLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value + (unit.isNotEmpty ? ' $unit' : ''),
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildChartSection(int targetMin, int targetMax) {
    if (_readings.length < 2) return const SizedBox.shrink();

    final recent = _readings.take(14).toList().reversed.toList();
    final values = recent.map((r) => r.value.toDouble()).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b).clamp(100.0, 400.0);
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
          Text(
            'Son ${recent.length} Ölçüm',
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Düşük',
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecLight,
                ),
              ),
              Text(
                'Hedef: $targetMin-$targetMax',
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Yüksek',
                style: AppTextStyles.label.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsList(int targetMin, int targetMax) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ölçüm Geçmişi',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (_readings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              border: Border.all(color: AppColors.backgroundLight),
            ),
            child: Text(
              'Kayıtlı ölçüm bulunamadı',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecLight,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _readings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final r = _readings[index];
              final status =
                  GlucoseReading.statusFromRange(r.value, targetMin, targetMax);
              return _ReadingTile(
                reading: r,
                status: status,
              );
            },
          ),
      ],
    );
  }
}

class _ReadingTile extends StatelessWidget {
  final GlucoseReading reading;
  final String status;

  const _ReadingTile({
    required this.reading,
    required this.status,
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
                Text(
                  '${reading.value} mg/dL',
                  style: AppTextStyles.h1.copyWith(fontSize: 20),
                ),
                Text(
                  dateStr,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: AppTextStyles.label.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
