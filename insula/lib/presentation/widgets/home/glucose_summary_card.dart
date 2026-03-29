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

  /// Returns the foreground color for a given glucose status string.
  Color _statusColor(String status) {
    if (status == 'Düşük') return Colors.orange.shade700;
    if (status == 'Yüksek') return Colors.red.shade700;
    return Colors.green.shade700;
  }

  Widget _buildStatusBadge(String status) {
    final fgColor = _statusColor(status);
    final bgColor = fgColor.withOpacity(0.1);
    IconData icon;
    if (status == 'Düşük') {
      icon = Icons.trending_down;
    } else if (status == 'Yüksek') {
      icon = Icons.trending_up;
    } else {
      icon = Icons.check_circle;
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
          Icon(icon, color: fgColor, size: 16),
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
        const displayMax = 200;
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

                  // Value – inherits status colour when out of range
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        glucose?.value.toString() ?? "—",
                        style: AppTextStyles.glucoseValue.copyWith(
                          color: status != null
                              ? _statusColor(status)
                              : AppTextStyles.glucoseValue.color,
                        ),
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

                  // Gradient Range Bar – orijinal renkler, ok göstergesi
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
                      // Ok göstergesi + çubuk
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const arrowSize = 12.0;
                          const barHeight = 12.0;
                          final arrowLeft =
                              ((constraints.maxWidth - arrowSize) * position)
                                  .clamp(0.0, constraints.maxWidth - arrowSize);
                          final arrowColor = status != null
                              ? _statusColor(status)
                              : AppColors.secondary;

                          return Column(
                            children: [
                              // Ok işareti satırı
                              SizedBox(
                                height: arrowSize,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (glucose != null)
                                      Positioned(
                                        left: arrowLeft,
                                        child: CustomPaint(
                                          size:
                                              const Size(arrowSize, arrowSize),
                                          painter: _DownArrowPainter(
                                              color: arrowColor),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Gradient çubuk
                              Container(
                                height: barHeight,
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
                                ),
                              ),
                            ],
                          );
                        },
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

/// Aşağı bakan dolu üçgen (ok) çizen CustomPainter.
class _DownArrowPainter extends CustomPainter {
  final Color color;
  const _DownArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownArrowPainter old) => old.color != color;
}
