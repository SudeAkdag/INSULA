import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'confirm_selection_button.dart';

/// Doz/Miktar seçimi için bottom sheet.
/// Seçilen ilaç türüne göre farklı miktar seçenekleri sunar.
class DoseAmountBottomSheet extends StatefulWidget {
  final String medicationType; // "Tablet", "Kapsül", "Enjeksiyon", "İnsülin", "Sprey", "Diğer"
  final String? initialValue;
  final void Function(String) onConfirm;

  const DoseAmountBottomSheet({
    super.key,
    required this.medicationType,
    this.initialValue,
    required this.onConfirm,
  });

  @override
  State<DoseAmountBottomSheet> createState() => _DoseAmountBottomSheetState();
}

class _DoseAmountBottomSheetState extends State<DoseAmountBottomSheet> {
  late String _selected;
  late TextEditingController _customController;
  late String _injectionUnit; // "mL" veya "U"

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();
    _injectionUnit = 'mL';

    final initial = widget.initialValue;
    if (initial != null && initial.isNotEmpty) {
      // initialValue'dan "Diğer (manuel)"i seç ve TextField'a doldur
      if (!_isValidOption(initial)) {
        _selected = 'Diğer (manuel)';
        _customController.text = initial;
      } else {
        _selected = initial;
      }
    } else {
      final options = _getOptions();
      _selected = options.isNotEmpty ? options.first : 'Diğer (manuel)';
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool _isValidOption(String value) {
    final options = _getOptions();
    return options.contains(value);
  }

  List<String> _getOptions() {
    switch (widget.medicationType) {
      case 'Tablet':
      case 'Kapsül':
        return ['0,5 adet', '1 adet', '1,5 adet', '2 adet', '3 adet', '4 adet', 'Diğer (manuel)'];
      case 'Sprey':
        return ['1 puf', '2 puf', '3 puf', '4 puf', 'Diğer (manuel)'];
      case 'İnsülin':
        return ['1 U', '2 U', '4 U', '6 U', '8 U', '10 U', '12 U', '14 U', '16 U', '20 U', 'Diğer (manuel)'];
      case 'Enjeksiyon':
        if (_injectionUnit == 'mL') {
          return ['0,25 mL', '0,5 mL', '1 mL', '2 mL', 'Diğer'];
        } else {
          return ['5 U', '10 U', '15 U', '20 U', 'Diğer'];
        }
      default:
        return ['Diğer (manuel)'];
    }
  }

  String _getTitle() {
    switch (widget.medicationType) {
      case 'Tablet':
      case 'Kapsül':
        return 'Miktar Seçin';
      case 'Sprey':
        return 'Puf Miktarı';
      case 'İnsülin':
      case 'Enjeksiyon':
        return 'Doz Miktarı';
      default:
        return 'Miktar Seçin';
    }
  }

  String _getSubtitle() {
    switch (widget.medicationType) {
      case 'Tablet':
      case 'Kapsül':
        return 'Kaç adet alacaksınız?';
      case 'Sprey':
        return 'Kaç puf kullanacaksınız?';
      case 'İnsülin':
        return 'Kaç ünite (U) enjekte edeceksiniz?';
      case 'Enjeksiyon':
        return 'Enjeksiyonun miktarını belirtin';
      default:
        return 'Miktarı girin';
    }
  }

  void _confirm() {
    if (_selected == 'Diğer (manuel)' || _selected == 'Diğer') {
      final customValue = _customController.text.trim();
      if (customValue.isEmpty) {
        return; // TextField boşsa confirm etme
      }
      widget.onConfirm(customValue);
    } else {
      widget.onConfirm(_selected);
    }
    Navigator.pop(context);
  }

  void _showCustomAmountDialog() {
    _customController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Özel Miktar Girin',
          style: AppTextStyles.h1.copyWith(
            fontSize: 18,
            color: AppColors.accentTeal,
          ),
        ),
        content: TextField(
          controller: _customController,
          decoration: InputDecoration(
            hintText: widget.medicationType == 'Diğer'
                ? 'Örn: 1 ölçek, 1 paket'
                : widget.medicationType == 'Sprey'
                    ? 'Örn: 5 puf'
                    : widget.medicationType == 'İnsülin'
                        ? 'Örn: 25 U'
                        : widget.medicationType == 'Enjeksiyon'
                            ? 'Örn: 0.75 mL'
                            : 'Örn: 2.5 adet',
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
                        _getTitle(),
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 22,
                          color: AppColors.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSubtitle(),
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Enjeksiyon için birim seçimi
                if (widget.medicationType == 'Enjeksiyon') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _injectionUnit = 'mL'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _injectionUnit == 'mL'
                                    ? AppColors.accentTeal.withOpacity(0.1)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _injectionUnit == 'mL'
                                      ? AppColors.accentTeal
                                      : Colors.grey.shade300,
                                  width: _injectionUnit == 'mL' ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                'mL',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _injectionUnit == 'mL'
                                      ? AppColors.accentTeal
                                      : AppColors.textMainLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _injectionUnit = 'U'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _injectionUnit == 'U'
                                    ? AppColors.accentTeal.withOpacity(0.1)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _injectionUnit == 'U'
                                      ? AppColors.accentTeal
                                      : Colors.grey.shade300,
                                  width: _injectionUnit == 'U' ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                'Ünite (U)',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _injectionUnit == 'U'
                                      ? AppColors.accentTeal
                                      : AppColors.textMainLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    itemCount: _getOptions().length,
                    itemBuilder: (context, index) {
                      final option = _getOptions()[index];
                      final isSelected = _selected == option;
                      final isCustom = option == 'Diğer (manuel)' || option == 'Diğer';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (isCustom) {
                                    _showCustomAmountDialog();
                                  } else {
                                    setState(() {
                                      _selected = option;
                                    });
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
                          ],
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
