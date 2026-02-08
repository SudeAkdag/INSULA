import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'confirm_selection_button.dart';

/// Sıklık seçimi (frequency/dosage frequency) için bottom sheet:
/// Günde 1 kez, Günde 2 kez, Günde 3 kez, vb.
class FrequencyBottomSheet extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onConfirm;

  const FrequencyBottomSheet({
    super.key,
    this.initialValue,
    required this.onConfirm,
  });

  static const List<FrequencyOption> options = [
    FrequencyOption('Günde 1 kez', Icons.filter_1, null),
    FrequencyOption('Günde 2 kez', Icons.filter_2, '(sabah–akşam)'),
    FrequencyOption('Günde 3 kez', Icons.filter_3, null),
    FrequencyOption('Günde 4 kez', Icons.filter_4, null),
    FrequencyOption('Gün aşırı', Icons.calendar_today, null),
    FrequencyOption('Haftada 1 kez', Icons.event_repeat, null),
    FrequencyOption('Diğer', Icons.edit_note, '(manuel giriş)'),
  ];

  @override
  State<FrequencyBottomSheet> createState() => _FrequencyBottomSheetState();
}

class FrequencyOption {
  final String title;
  final IconData icon;
  final String? subtitle;

  const FrequencyOption(this.title, this.icon, this.subtitle);
}

class _FrequencyBottomSheetState extends State<FrequencyBottomSheet> {
  late String _selected;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    final validTitles = FrequencyBottomSheet.options.map((o) => o.title).toList();
    _selected = (initial != null && validTitles.contains(initial)) ? initial : validTitles.first;
    
    // Initialize custom input controller
    _customController = TextEditingController();
    if (initial != null && !validTitles.contains(initial)) {
      _selected = initial;
      _customController.text = initial;
    }
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

  void _showCustomFrequencyDialog() {
    _customController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Özel Sıklık Girin',
          style: AppTextStyles.h1.copyWith(
            fontSize: 18,
            color: AppColors.accentTeal,
          ),
        ),
        content: TextField(
          controller: _customController,
          decoration: InputDecoration(
            hintText: 'Örn: Her 2 hafta, Her gün sabah',
            hintStyle: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: AppColors.textSecLight,
            ),
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accentTeal,
                width: 2,
              ),
            ),
          ),
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: AppColors.textMainLight,
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İptal',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final input = _customController.text.trim();
              if (input.isNotEmpty) {
                setState(() => _selected = input);
                Navigator.pop(ctx);
              }
            },
            child: Text(
              'Kaydet',
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
                        'Sıklık Seçin',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 22,
                          color: AppColors.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'İlacı ne sıklıkla kullanacağınızı belirtin',
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
                    itemCount: FrequencyBottomSheet.options.length,
                    itemBuilder: (context, index) {
                      final option = FrequencyBottomSheet.options[index];
                      final isOther = option.title == 'Diğer';
                      final isSelected = isOther 
                          ? !FrequencyBottomSheet.options.map((o) => o.title).contains(_selected)
                          : _selected == option.title;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (isOther) {
                                _showCustomFrequencyDialog();
                              } else {
                                setState(() => _selected = option.title);
                              }
                            },
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
                                      color: AppColors.accentTeal.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: AppColors.accentTeal,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Show custom value if "Diğer" is selected and has custom input
                                        if (isOther && isSelected && !FrequencyBottomSheet.options.map((o) => o.title).contains(_selected)) ...[
                                          Text(
                                            _selected,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: AppColors.accentTeal,
                                            ),
                                          ),
                                        ] else ...[
                                          Text(
                                            option.title,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: AppColors.accentTeal,
                                            ),
                                          ),
                                        ],
                                        if (option.subtitle != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            option.subtitle!,
                                            style: AppTextStyles.body.copyWith(
                                              fontSize: 12,
                                              color: AppColors.textSecLight,
                                            ),
                                          ),
                                        ],
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
