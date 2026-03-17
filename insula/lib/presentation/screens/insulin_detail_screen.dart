// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/data/models/insulin_log_model.dart';
import 'package:insula/data/services/insulin_service.dart';
import 'package:insula/presentation/screens/insulin_entry_screen.dart';

/// İnsülin geçmişi detay sayfası — tarih picker + günlük özet + liste.
class InsulinDetailScreen extends StatefulWidget {
  const InsulinDetailScreen({super.key});

  @override
  State<InsulinDetailScreen> createState() => _InsulinDetailScreenState();
}

class _InsulinDetailScreenState extends State<InsulinDetailScreen> {
  final InsulinService _insulinService = InsulinService();

  List<InsulinLog> _logs = [];
  bool _isLoading = true;
  String? _errorMessage;

  DateTime _selectedDate = DateTime.now();

  DateTime get _selectedDay => DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day);

  List<InsulinLog> get _filtered => _logs.where((log) {
        final d = DateTime(log.timestamp.year, log.timestamp.month,
            log.timestamp.day);
        return d == _selectedDay;
      }).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await _insulinService.getInsulinLogs(limit: 300);
      if (mounted) {
        setState(() {
          _logs = list;
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

  void _openEntry() {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => InsulinEntryScreen(onSaved: _load),
        ))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
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
          'İnsülin Geçmişi',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEntry,
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add),
        label: const Text('Kayıt Ekle'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary))
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.secondary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Yapışkan tarih picker
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        floating: false,
                        backgroundColor: AppColors.backgroundLight,
                        expandedHeight: 0,
                        toolbarHeight: 0,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(100),
                          child: _buildDatePicker(),
                        ),
                      ),
                      // İçerik
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildDaySummary(),
                            const SizedBox(height: 20),
                            _buildHistoryList(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ── Tarih Picker ────────────────────────────────────────────────────────────
  Widget _buildDatePicker() {
    final today = DateTime.now();
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
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: days.length,
              itemBuilder: (context, i) {
                final d = days[i];
                final isSelected =
                    DateTime(d.year, d.month, d.day) == _selectedDay;
                final hasData = _logs.any((log) {
                  final ld = DateTime(log.timestamp.year,
                      log.timestamp.month, log.timestamp.day);
                  return ld == DateTime(d.year, d.month, d.day);
                });

                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedDate = d),
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
                                color:
                                    AppColors.secondary.withOpacity(0.3),
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

  // ── Günlük Özet ─────────────────────────────────────────────────────────────
  Widget _buildDaySummary() {
    final data = _filtered;
    final totalUnits =
        data.fold<double>(0.0, (s, l) => s + l.units);
    final activeCount = data.where((l) => l.isActive).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: const Border(
            left: BorderSide(color: AppColors.secondary, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: data.isEmpty
          ? Column(
              children: [
                const Icon(Icons.vaccines_outlined,
                    size: 40, color: AppColors.textSecLight),
                const SizedBox(height: 8),
                Text(
                  'Bu gün için insülin kaydı yok',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecLight,
                      fontWeight: FontWeight.w600),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Toplam',
                  value: totalUnits.toStringAsFixed(1),
                  unit: 'ünite',
                ),
                _StatItem(
                  label: 'Kayıt',
                  value: '${data.length}',
                  unit: 'adet',
                ),
                _StatItem(
                  label: 'Aktif',
                  value: '$activeCount',
                  unit: 'doz',
                ),
              ],
            ),
    );
  }

  // ── Geçmiş Listesi ──────────────────────────────────────────────────────────
  Widget _buildHistoryList() {
    final data = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kayıt Geçmişi',
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
              'Bu tarih için kayıt bulunamadı',
              style: AppTextStyles.label
                  .copyWith(color: AppColors.textSecLight),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _InsulinLogTile(log: data[i]),
          ),
      ],
    );
  }

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
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecLight),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
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
}

// ── Yardımcı Widget'lar ───────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatItem(
      {required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: AppTextStyles.label
                .copyWith(fontSize: 11, color: AppColors.textSecLight)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h1.copyWith(fontSize: 20)),
        Text(unit,
            style: AppTextStyles.label
                .copyWith(fontSize: 11, color: AppColors.textSecLight)),
      ],
    );
  }
}

class _InsulinLogTile extends StatelessWidget {
  final InsulinLog log;

  const _InsulinLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isActive = log.isActive;
    final activeColor = AppColors.secondary;
    final inactiveColor = AppColors.textSecLight;
    final tileColor = isActive ? activeColor : inactiveColor;
    final h = log.timestamp.hour.toString().padLeft(2, '0');
    final m = log.timestamp.minute.toString().padLeft(2, '0');

    String remainingText = '';
    if (isActive) {
      final rem = log.remainingDuration;
      if (rem.inHours > 0) {
        remainingText =
            '${rem.inHours}sa ${rem.inMinutes.remainder(60)}dk kaldı';
      } else {
        remainingText = '${rem.inMinutes}dk kaldı';
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
          // Renk bandı
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          // İkon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tileColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.vaccines_rounded,
                color: tileColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Bilgi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${log.units.toStringAsFixed(1)} ünite',
                      style: AppTextStyles.h1.copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tileColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log.type,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 10,
                          color: tileColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$h:$m • ${log.site}${log.note != null ? ' • ${log.note}' : ''}',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecLight,
                  ),
                ),
              ],
            ),
          ),
          // Kalan süre / bitti
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isActive) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Aktif',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10,
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remainingText,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10,
                    color: activeColor.withOpacity(0.7),
                  ),
                ),
              ] else
                Text(
                  'Bitti',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 11,
                    color: inactiveColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
