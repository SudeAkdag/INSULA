import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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

  static const List<UsageTimeOption> defaultOptions = [
    UsageTimeOption('Sabah', Icons.light_mode, Color(0xFFFFF8E1), AppColors.primary),
    UsageTimeOption('Öğle', Icons.wb_sunny, Color(0xFFFFECB3), Color(0xFFFF9800)),
    UsageTimeOption('Akşam', Icons.nightlight_round, Color(0xFFE8EAF6), Color(0xFF5C6BC0)),
  ];

  static const UsageTimeOption otherOption = UsageTimeOption('Diğer', Icons.add_circle_outline, Color(0xFFF3E5F5), Color(0xFF9C27B0));

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
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    final validTitles = UsageTimeBottomSheet.defaultOptions.map((o) => o.title).toList();
    _selected = (initial != null && validTitles.contains(initial)) ? initial : validTitles.first;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
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
                      children: [
                        ...UsageTimeBottomSheet.defaultOptions.map((option) {
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
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: AppColors.accentTeal,
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                _customController.clear();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext ctx) => AlertDialog(
                                    title: const Text('Diğer Kullanım Zamanı'),
                                    content: TextField(
                                      controller: _customController,
                                      decoration: InputDecoration(
                                        hintText: 'Örn: Spor, Yemekten sonra',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('İptal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final text = _customController.text.trim();
                                          if (text.isNotEmpty) {
                                            setState(() {
                                              _selected = text;
                                            });
                                            Navigator.pop(ctx);
                                          }
                                        },
                                        child: const Text('Tamam'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: ((_selected != 'Sabah' && _selected != 'Öğle' && _selected != 'Akşam') ? const Color(0xFFe6f4f6) : Colors.transparent),
                                    width: ((_selected != 'Sabah' && _selected != 'Öğle' && _selected != 'Akşam') ? 1.5 : 0),
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
                                        color: UsageTimeBottomSheet.otherOption.iconBgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        UsageTimeBottomSheet.otherOption.icon,
                                        color: UsageTimeBottomSheet.otherOption.iconColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        UsageTimeBottomSheet.otherOption.title,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppColors.accentTeal,
                                        ),
                                      ),
                                    ),
                                    _buildRadio(_selected != 'Sabah' && _selected != 'Öğle' && _selected != 'Akşam'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
