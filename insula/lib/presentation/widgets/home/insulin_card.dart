// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/home_viewmodel.dart';
import 'package:insula/presentation/screens/insulin_entry_screen.dart';
import 'package:insula/presentation/screens/insulin_detail_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class InsulinCard extends StatelessWidget {
  const InsulinCard({super.key});

  String _formatDuration(Duration d) {
    if (d.inMinutes <= 0) return 'Bitti';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}sa ${minutes}dk kaldı';
    return '${minutes}dk kaldı';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _openEntry(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => InsulinEntryScreen(
            onSaved: () => context.read<HomeViewModel>().refresh(),
          ),
        ))
        .then((_) => context.read<HomeViewModel>().refresh());
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const InsulinDetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        final log = vm.latestActiveInsulin;
        final hasActiveInsulin = log != null && log.isActive;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffffffff),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffffffff).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                bottom: -24,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                children: [
                  // ── Başlık ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.vaccines,
                              color: AppColors.secondary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "AKTİF İNSÜLİN",
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.secondary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hasActiveInsulin
                              ? "Son: ${_formatTime(log.timestamp)}"
                              : "Kayıt yok",
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── İçerik ───────────────────────────────────────
                  if (hasActiveInsulin) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDuration(log.remainingDuration),
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Doz: ${log.units.toStringAsFixed(1)} Ü  •  Bölge: ${log.site}",
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.secondary.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.schedule,
                                      size: 14,
                                      color:
                                          AppColors.secondary.withOpacity(0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Tahmini bitiş: ${_formatTime(log.estimatedEndTime)}",
                                    style: AppTextStyles.label.copyWith(
                                      fontSize: 11,
                                      color:
                                          AppColors.secondary.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _ActionButton(
                          icon: Icons.add,
                          onTap: () => _openEntry(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 1 -
                            (log.remainingDuration.inMinutes /
                                (log.durationHours * 60)),
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.secondary),
                        minHeight: 6,
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Aktif insülin yok",
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.secondary.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "İnsülin kaydı ekleyerek takip edebilirsiniz",
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 11,
                                  color: AppColors.secondary.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _ActionButton(
                          icon: Icons.add,
                          onTap: () => _openEntry(context),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── Detaylar bağlantısı ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _openDetail(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Detaylar",
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.secondary),
        onPressed: onTap,
      ),
    );
  }
}
