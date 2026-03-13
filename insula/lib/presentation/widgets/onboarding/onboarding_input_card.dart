import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';

/// Erişilebilir, yumuşak gölgeli ve ikonlu giriş kartı.
class OnboardingInputCard extends StatelessWidget {
  const OnboardingInputCard({
    super.key,
    required this.child,
    this.icon,
    this.label,
  });

  final Widget child;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null || icon != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.secondary, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (label != null)
                    Text(
                      label!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMainLight,
                      ),
                    ),
                ],
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              (label != null || icon != null) ? 0 : AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
