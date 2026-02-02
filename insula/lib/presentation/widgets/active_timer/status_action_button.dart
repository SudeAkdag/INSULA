import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StatusActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const StatusActionButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
      ]),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          padding: EdgeInsets.zero, // İçerik sıkışmasın diye
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              child: Text(label, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            if (label == "Tamamladım") ...[
              const SizedBox(width: 20),
              const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
            ]
          ],
        ),
      ),
    );
  }
}