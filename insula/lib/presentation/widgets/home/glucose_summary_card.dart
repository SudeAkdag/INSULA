// ignore_for_file: use_build_context_synchronously, deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/home_viewmodel.dart';
import 'package:insula/presentation/widgets/home/bottom_sheets/glucose_entry_bottom_sheet.dart';
import 'package:insula/presentation/screens/glucose_detail_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GlucoseSummaryCard extends StatelessWidget {
  const GlucoseSummaryCard({super.key});

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color fgColor;
    if (status == 'Düşük') {
      bgColor = Colors.orange.withOpacity(0.1);
      fgColor = Colors.orange.shade700;
    } else if (status == 'Yüksek') {
      bgColor = Colors.red.withOpacity(0.1);
      fgColor = Colors.red.shade700;
    } else {
      bgColor = Colors.green.withOpacity(0.1);
      fgColor = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fgColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'Yüksek' ? Icons.trending_up : Icons.check_circle,
            color: fgColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTextStyles.label.copyWith(
              color: fgColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
        final glucose = vm.latestGlucose;
        final status = glucose != null ? vm.glucoseStatus(glucose.value) : null;
        const displayMin = 40;
        const displayMax = 300;
        final value = glucose?.value ?? 100;
        final position =
            ((value - displayMin) / (displayMax - displayMin)).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: const Border(
              left: BorderSide(color: AppColors.primary, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background Decor (Blur) - Simplified as Flutter shadow/blur handling can be complex
              // Leaving out the absolute positioned blur for performance/simplicity for now, can add if needed as a blurred container.

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ŞEKER SEVİYESİ",
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            glucose != null
                                ? "Son ölçüm: ${_formatTimeAgo(glucose.timestamp)}"
                                : "Ölçüm eklenmedi",
                            style: AppTextStyles.label.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                      if (status != null) _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Value
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        glucose?.value.toString() ?? "—",
                        style: AppTextStyles.glucoseValue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "mg/dL",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Gradient Range Bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Düşük",
                              style: AppTextStyles.label.copyWith(
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(
                              "Hedef: ${vm.targetGlucoseMin}-${vm.targetGlucoseMax}",
                              style: AppTextStyles.label.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary)),
                          Text("Yüksek",
                              style: AppTextStyles.label.copyWith(
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.tertiary, // Orange
                                    AppColors.primary, // Yellow
                                    AppColors.secondary, // Teal (Target)
                                    AppColors.primary,
                                    AppColors.tertiary,
                                  ],
                                  stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                                ),
                                color: Colors.grey.shade200, // Fallback
                              ),
                              child: Opacity(
                                opacity: 0.8,
                                child: Container(),
                              ),
                            ),
                            // Indicator
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final left =
                                    ((constraints.maxWidth - 6) * position)
                                        .clamp(0.0, constraints.maxWidth - 6);
                                return Positioned(
                                  left: left,
                                  top: 0,
                                  bottom: 0,
                                  child: Transform.translate(
                                    offset: const Offset(
                                        -3, 0), // Center the marker width (6px)
                                    child: Container(
                                      width: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showGlucoseEntryBottomSheet(
                            context,
                            onSaved: () =>
                                context.read<HomeViewModel>().refresh(),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 18,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Ölçüm Ekle",
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => GlucoseDetailScreen(
                                targetMin: vm.targetGlucoseMin,
                                targetMax: vm.targetGlucoseMax,
                              ),
                            ),
                          )
                              .then((_) {
                            context.read<HomeViewModel>().refresh();
                          });
                        },
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
