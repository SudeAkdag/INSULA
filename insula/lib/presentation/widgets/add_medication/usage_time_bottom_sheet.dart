import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'confirm_selection_button.dart';

/// Kullanım zamanı seçimi için bottom sheet: Sabah, Öğle, Akşam, Fark Etmez.
/// Doz kartlarındaki "KULLANIM ZAMANI" alanına tıklandığında gösterilir.
/// "Seçimi Onayla" butonu İlaç Türü sheet'i ile aynı tasarımda (teal arka plan, sarı yazı + ikon, gölge).
///
/// İstek: Sayfa/ekran alanına göre boyutlansın; tüm seçenekler görünecek şekilde uzayabilsin.
/// (Yarım ekran zorunlu değil. Gerekirse maksimum ekranın %90'ına kadar büyür, sığmazsa kaydırılır.)
class UsageTimeBottomSheet extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onConfirm;

  const UsageTimeBottomSheet({
    super.key,
    this.initialValue,
    required this.onConfirm,
  });

  static const List<UsageTimeOption> options = [
    UsageTimeOption('Sabah', Icons.light_mode, Color(0xFFFFF8E1), AppColors.primary),
    UsageTimeOption('Öğle', Icons.wb_sunny, Color(0xFFFFECB3), Color(0xFFFF9800)),
    UsageTimeOption('Akşam', Icons.nightlight_round, Color(0xFFE8EAF6), Color(0xFF5C6BC0)),
    UsageTimeOption('Fark Etmez', Icons.calendar_today, Color(0xFFEEEEEE), Color(0xFF757575)),
  ];

  @override
  State<UsageTimeBottomSheet> createState() => _UsageTimeBottomSheetState();
}

class UsageTimeOption {
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const UsageTimeOption(this.title, this.icon, this.iconBgColor, this.iconColor);
}

class _UsageTimeBottomSheetState extends State<UsageTimeBottomSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    final validTitles = UsageTimeBottomSheet.options.map((o) => o.title).toList();
    _selected = (initial != null && validTitles.contains(initial)) ? initial : validTitles.first;
  }

  void _confirm() {
    widget.onConfirm(_selected);
    Navigator.pop(context);
  }

  static const Color _radioBorderLight = Color(0xFFcee4e9);

  Widget _buildRadio(bool selected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _radioBorderLight,
          width: 2,
        ),
        color: selected ? AppColors.accentTeal : Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Bottom sheet yarım ekrana sıkışmasın:
        // İçerik kısa ise kendi boyuna göre,
        // uzun ise ekranın %90'ına kadar uzasın (fazlası scroll).
        final maxH = constraints.maxHeight * 0.90;

        return Container(
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
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
                          'Kullanım Zamanı',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 22,
                            color: AppColors.accentTeal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'İlacınızı ne zaman alacağınızı seçin',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: UsageTimeBottomSheet.options.map((option) {
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
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFcee4e9) : Colors.transparent,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accentTeal.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: option.iconBgColor,
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
                                      child: Text(
                                        option.title,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMainLight,
                                        ),
                                      ),
                                    ),
                                    _buildRadio(isSelected),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: ConfirmSelectionButton(onPressed: _confirm),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
