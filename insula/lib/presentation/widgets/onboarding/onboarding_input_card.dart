import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';

/// Erişilebilir, yumuşak gölgeli ve ikonlu giriş kartı.
/// [hasError] true ise kart kenarlığı ve ikon kırmızıya döner.
class OnboardingInputCard extends StatelessWidget {
  const OnboardingInputCard({
    super.key,
    required this.child,
    this.icon,
    this.label,
    this.hasError = false,
  });

  final Widget child;
  final IconData? icon;
  final String? label;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final iconColor = hasError ? Colors.red.shade600 : AppColors.secondary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: hasError
            ? Colors.red.shade50
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(
          color: hasError ? Colors.red.shade400 : Colors.transparent,
          width: hasError ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? Colors.red.withAlpha(20)
                : AppColors.secondary.withAlpha(15),
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
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (label != null)
                    Text(
                      label!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: hasError
                            ? Colors.red.shade700
                            : AppColors.textMainLight,
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
