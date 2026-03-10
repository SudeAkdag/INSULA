import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/data/services/glucose_service.dart';

/// Kan şekeri ölçümü ekleme bottom sheet.
void showGlucoseEntryBottomSheet(
  BuildContext context, {
  required VoidCallback onSaved,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _GlucoseEntryBottomSheet(onSaved: onSaved),
  );
}

class _GlucoseEntryBottomSheet extends StatefulWidget {
  final VoidCallback onSaved;

  const _GlucoseEntryBottomSheet({required this.onSaved});

  @override
  State<_GlucoseEntryBottomSheet> createState() =>
      _GlucoseEntryBottomSheetState();
}

class _GlucoseEntryBottomSheetState extends State<_GlucoseEntryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _glucoseService = GlucoseService();

  bool _isSaving = false;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final value = int.tryParse(_valueController.text.trim());
    if (value == null || value < 20 || value > 600) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir değer girin (20 - 600 mg/dL)'),
          backgroundColor: AppColors.tertiary,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _glucoseService.addGlucoseReading(value: value);
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      navigator.pop();
      widget.onSaved();
      messenger.showSnackBar(
        SnackBar(
          content: Text('$value mg/dL kan şekeri kaydedildi'),
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
                  'Kan Şekeri Ölçümü',
                  style: AppTextStyles.h1.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ölçtüğünüz kan şekeri değerini girin',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Değer
                Text(
                  'Kan şekeri (mg/dL)',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'örn. 105',
                    suffixText: 'mg/dL',
                    suffixStyle: AppTextStyles.label.copyWith(
                      color: AppColors.textSecLight,
                    ),
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
                      return 'Değer girin';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 20 || n > 600) {
                      return '20 - 600 arası girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Hedef aralık genelde 70-140 mg/dL\'dir',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecLight,
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
