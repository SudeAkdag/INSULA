// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/home_viewmodel.dart';
import 'package:insula/presentation/widgets/home/bottom_sheets/glucose_entry_bottom_sheet.dart';
import 'package:insula/presentation/screens/glucose_detail_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Tip 1 diyabet hastaları için özelleştirilmiş şeker seviyesi kartı.
/// Önerilen insülin ve aktif karbonhidrat değerlerini gösterir.
class Type1GlucoseSummaryCard extends StatelessWidget {
  const Type1GlucoseSummaryCard({super.key});

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
        final recommendedInsulin = vm.totalRecommendedInsulin;
        final todayCarbs = vm.todayCarbs;
        final todayInsulin = vm.todayInsulinTotal;
        final status = glucose != null ? vm.glucoseStatus(glucose.value) : null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
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
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "KAN ŞEKERİ",
                            style: AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Tip 1",
                              style: AppTextStyles.label.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        ],
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

              // Kan şekeri değeri
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    glucose?.value.toString() ?? "—",
                    style: AppTextStyles.glucoseValue.copyWith(fontSize: 52),
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

              const SizedBox(height: 20),

              // Tip 1 özel: Önerilen insülin + Aktif karbonhidrat + Günlük toplam
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            icon: Icons.vaccines,
                            label: "Önerilen İnsülin",
                            value: recommendedInsulin > 0
                                ? "${recommendedInsulin.toStringAsFixed(1)} Ü"
                                : "—",
                            color: AppColors.secondary,
                            isFirst: true,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoChip(
                            icon: Icons.bakery_dining,
                            label: "Aktif Karb",
                            value: "${todayCarbs.toInt()}g",
                            color: AppColors.tertiary,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoChip(
                            icon: Icons.medication,
                            label: "Günlük Toplam",
                            value: todayInsulin > 0
                                ? "${todayInsulin.toStringAsFixed(1)} Ü"
                                : "—",
                            color: Colors.purple.shade600,
                            isLast: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Besin sayfasındaki karbonhidrata göre hesaplanır",
                      style: AppTextStyles.label.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Gradient bar - hedef aralığa göre
              _buildRangeBar(
                glucose?.value ?? 100,
                vm.targetGlucoseMin,
                vm.targetGlucoseMax,
              ),

              const SizedBox(height: 16),

              // Ölçüm Ekle & Detaylar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      showGlucoseEntryBottomSheet(
                        context,
                        onSaved: () => context.read<HomeViewModel>().refresh(),
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
                        // ignore: use_build_context_synchronously
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
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color fgColor;
    IconData icon = Icons.check_circle;
    if (status == 'Düşük') {
      bgColor = Colors.orange.withOpacity(0.1);
      fgColor = Colors.orange.shade700;
    } else if (status == 'Yüksek') {
      bgColor = Colors.red.withOpacity(0.1);
      fgColor = Colors.red.shade700;
      icon = Icons.trending_up;
    } else {
      // Hedefte / Normal
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFirst = false, // Yeni parametre
    bool isLast = false, // Yeni parametre
  }) {
    return Expanded(
      child: Container(
        // Kenarlara yaslanması için margin'leri düzenledik
        margin: EdgeInsets.only(
          left: isFirst ? 0 : 4,
          right: isLast ? 0 : 4,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Flexible(
                  // Yazı sığmazsa taşmasın diye
                  child: Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 9,
                      color: AppColors.textSecLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.h1.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeBar(int value, int targetMin, int targetMax) {
    const displayMin = 40;
    const displayMax = 300;
    final position =
        ((value - displayMin) / (displayMax - displayMin)).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Düşük",
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Hedef: $targetMin-$targetMax",
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            Text(
              "Yüksek",
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 12,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.tertiary,
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.primary,
                      AppColors.tertiary,
                    ],
                    stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final left = ((constraints.maxWidth - 6) * position)
                      .clamp(0.0, constraints.maxWidth - 6);
                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
