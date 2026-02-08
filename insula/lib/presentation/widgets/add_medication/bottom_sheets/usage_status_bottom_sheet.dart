import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'confirm_selection_button.dart';

/// Durum seçimi (medication status/condition) için bottom sheet: 
/// Aç Karnına, Tok Karnına, Yemekle Birlikte, Yemekten Önce, Yemekten Sonra, Fark Etmez
class UsageStatusBottomSheet extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onConfirm;

  const UsageStatusBottomSheet({
    super.key,
    this.initialValue,
    required this.onConfirm,
  });

  static const List<UsageStatusOption> options = [
    UsageStatusOption(
      'Aç Karnına',
      Icons.fastfood,
      Color(0xFFF5F5F5),
      AppColors.accentTeal,
      'Yemekten en az 1 saat önce',
    ),
    UsageStatusOption(
      'Tok Karnına',
      Icons.restaurant,
      Color(0xFFF5F5F5),
      AppColors.accentTeal,
      'Yemekten hemen sonra',
    ),
    UsageStatusOption(
      'Yemekle Birlikte',
      Icons.dining,
      Color(0xFFF5F5F5),
      AppColors.accentTeal,
      'Yemek esnasında alınız',
    ),
    UsageStatusOption(
      'Yemekten Önce',
      Icons.schedule,
      Color(0xFFF5F5F5),
      AppColors.accentTeal,
      'Öğünden 30 dakika önce',
    ),
    UsageStatusOption(
      'Yemekten Sonra',
      Icons.update,
      Color(0xFFF5F5F5),
      AppColors.accentTeal,
      'Öğünden 30 dakika sonra',
    ),
    UsageStatusOption(
      'Fark Etmez',
      Icons.check_circle,
      Color(0xFFF5F5F5),
      AppColors.accentTeal,
      'Beslenme düzeninden bağımsız',
    ),
  ];

  @override
  State<UsageStatusBottomSheet> createState() => _UsageStatusBottomSheetState();
}

class UsageStatusOption {
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String description;

  const UsageStatusOption(
    this.title,
    this.icon,
    this.iconBgColor,
    this.iconColor,
    this.description,
  );
}

class _UsageStatusBottomSheetState extends State<UsageStatusBottomSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    final validTitles = UsageStatusBottomSheet.options.map((o) => o.title).toList();
    _selected = (initial != null && validTitles.contains(initial)) ? initial : validTitles.first;
  }

  void _confirm() {
    widget.onConfirm(_selected);
    Navigator.pop(context);
  }

  Widget _buildRadio(bool selected) {
    if (selected) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: AppColors.accentTeal, width: 2.5),
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        color: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Force sheet to occupy 82% of the device screen height so
        // it reliably covers most of the screen even if caller
        // didn't set isScrollControlled.
        final maxH = MediaQuery.of(context).size.height * 0.82;

        return Container(
          height: maxH,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Durum Seçimi',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 22,
                          color: AppColors.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'İlacınızı ne zaman almanız gerektiğini seçin',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    itemCount: UsageStatusBottomSheet.options.length,
                    itemBuilder: (context, index) {
                      final option = UsageStatusBottomSheet.options[index];
                      final isSelected = _selected == option.title;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _selected = option.title),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFe6f4f6) : Colors.transparent,
                                  width: isSelected ? 1.5 : 0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: option.iconBgColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: option.iconColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: AppTextStyles.body.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColors.accentTeal,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option.description,
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 12,
                                            color: AppColors.textSecLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildRadio(isSelected),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withOpacity(0.95),
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: ConfirmSelectionButton(onPressed: _confirm),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
