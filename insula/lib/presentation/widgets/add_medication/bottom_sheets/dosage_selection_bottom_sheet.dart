import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'confirm_selection_button.dart';

/// Dozaj seçimi için bottom sheet.
/// Sabit dozaj seçeneklerini gösterir: 5 mg, 10 mg, 20 mg, 25 mg, 50 mg, 100 mg, 150 mg, Diğer (manuel gir)
class DosageSelectionBottomSheet extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onConfirm;

  const DosageSelectionBottomSheet({
    super.key,
    this.initialValue,
    required this.onConfirm,
  });

  static const List<String> options = [
    '5 mg',
    '10 mg',
    '20 mg',
    '25 mg',
    '50 mg',
    '100 mg',
    '150 mg',
  ];

  @override
  State<DosageSelectionBottomSheet> createState() =>
      _DosageSelectionBottomSheetState();
}

class _DosageSelectionBottomSheetState
    extends State<DosageSelectionBottomSheet> {
  late String _selected;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();

    final initial = widget.initialValue;
    if (initial != null && initial.isNotEmpty) {
      if (DosageSelectionBottomSheet.options.contains(initial)) {
        _selected = initial;
      } else {
        _selected = 'Diğer (manuel gir)';
        _customController.text = initial;
      }
    } else {
      _selected = DosageSelectionBottomSheet.options.first;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_selected == 'Diğer (manuel gir)') {
      final customValue = _customController.text.trim();
      if (customValue.isEmpty) {
        return;
      }
      widget.onConfirm(customValue);
    } else {
      widget.onConfirm(_selected);
    }
    Navigator.pop(context);
  }

  void _showCustomDosageDialog() {
    _customController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Özel Dozaj Girin',
          style: AppTextStyles.h1.copyWith(
            fontSize: 18,
            color: AppColors.accentTeal,
          ),
        ),
        content: TextField(
          controller: _customController,
          decoration: InputDecoration(
            hintText: 'Örn: 15 mg, 200 mg',
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
        final maxH = MediaQuery.of(context).size.height * 0.82;

        return Container(
          height: maxH,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                        'Dozaj Seçim Ekranı',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 22,
                          color: AppColors.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lütfen ilacınızın dozaj miktarını seçin.',
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
                    itemCount: DosageSelectionBottomSheet.options.length + 1,
                    itemBuilder: (context, index) {
                      // First 7 items are standard options, last item is "Diğer (manuel gir)"
                      if (index < DosageSelectionBottomSheet.options.length) {
                        final option = DosageSelectionBottomSheet.options[index];
                        final isSelected = _selected == option;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selected = option;
                                });
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
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
                                      child: const Icon(
                                        Icons.monitor_weight,
                                        color: AppColors.accentTeal,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        option,
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
                      } else {
                        // "Diğer (manuel gir)" option
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                      _showCustomDosageDialog();
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: _selected == 'Diğer (manuel gir)'
                                            ? const Color(0xFFe6f4f6)
                                            : Colors.transparent,
                                        width: _selected == 'Diğer (manuel gir)'
                                            ? 1.5
                                            : 0,
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
                                          child: const Icon(
                                            Icons.edit,
                                            color: AppColors.accentTeal,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            'Diğer (manuel gir)',
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: AppColors.accentTeal,
                                            ),
                                          ),
                                        ),
                                        _buildRadio(
                                          _selected == 'Diğer (manuel gir)',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
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
