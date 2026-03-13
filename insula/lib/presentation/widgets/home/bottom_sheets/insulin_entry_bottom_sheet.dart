// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/data/services/insulin_service.dart';

/// İnsülin kaydı ekleme bottom sheet.
void showInsulinEntryBottomSheet(
  BuildContext context, {
  required VoidCallback onSaved,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _InsulinEntryBottomSheet(onSaved: onSaved),
  );
}

class _InsulinEntryBottomSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const _InsulinEntryBottomSheet({required this.onSaved});

  @override
  State<_InsulinEntryBottomSheet> createState() =>
      _InsulinEntryBottomSheetState();
}

class _InsulinEntryBottomSheetState extends State<_InsulinEntryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  final _noteController = TextEditingController();
  final _insulinService = InsulinService();

  String _selectedType = 'Hızlı etkili';
  static const _insulinTypes = ['Hızlı etkili', 'Uzun etkili', 'Karma'];

  bool _isSaving = false;

  @override
  void dispose() {
    _unitsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final units = double.tryParse(
      _unitsController.text.trim().replaceAll(',', '.'),
    );
    if (units == null || units <= 0 || units > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir doz girin (0,1 - 100)'),
          backgroundColor: AppColors.tertiary,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _insulinService.addInsulinLog(
        units: units,
        type: _selectedType,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      navigator.pop();
      widget.onSaved();
      messenger.showSnackBar(
        SnackBar(
          content: Text('${units.toStringAsFixed(1)} ünite insülin kaydedildi'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt başarısız: $e'),
          backgroundColor: AppColors.tertiary,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.navBar,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'İnsülin Kaydı',
                  style: AppTextStyles.h1.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aldığınız insülin miktarını kaydedin',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecLight,
                  ),
                ),
                const SizedBox(height: 24),

                // İnsülin tipi
                Text(
                  'İnsülin tipi',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _insulinTypes.map((type) {
                    final isSelected = _selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedType = type),
                      selectedColor: AppColors.secondary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.textSecLight,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.backgroundLight,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Doz (ünite)
                Text(
                  'Doz (Ünite)',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _unitsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'örn. 4.5',
                    suffixText: 'Ü',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.defaultRadius),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.defaultRadius),
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Doz girin';
                    }
                    final n = double.tryParse(
                      v.trim().replaceAll(',', '.'),
                    );
                    if (n == null || n <= 0 || n > 100) {
                      return '0,1 - 100 arası girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Not (isteğe bağlı)
                Text(
                  'Not (isteğe bağlı)',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Örn: Öğle yemeği öncesi',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.defaultRadius),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Kaydet
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.defaultRadius),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
