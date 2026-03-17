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
  String _selectedContext = 'Açlık';

  static const List<Map<String, dynamic>> _contexts = [
    {'label': 'Açlık', 'icon': Icons.restaurant},
    {'label': 'Yemek öncesi', 'icon': Icons.ramen_dining},
    {'label': 'Yemek sonrası', 'icon': Icons.rice_bowl},
    {'label': 'Egzersiz öncesi', 'icon': Icons.directions_run},
    {'label': 'Egzersiz sonrası', 'icon': Icons.self_improvement},
    {'label': 'Genel', 'icon': Icons.person_outline},
  ];

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
      await _glucoseService.addGlucoseReading(
        value: value,
        context: _selectedContext,
      );
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      navigator.pop();
      widget.onSaved();
      messenger.showSnackBar(
        SnackBar(
          content: Text('$_selectedContext • $value mg/dL kaydedildi'),
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

                Text(
                  'Geçerli durumu seç',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _contexts.map((c) {
                    final label = c['label'] as String;
                    final icon = c['icon'] as IconData;
                    final selected = _selectedContext == label;
                    return InkWell(
                      onTap: () => setState(() => _selectedContext = label),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 110,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.secondary.withOpacity(0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? AppColors.secondary.withOpacity(0.35)
                                : AppColors.navBar.withOpacity(0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.secondary.withOpacity(0.18)
                                    : AppColors.backgroundLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: selected
                                    ? AppColors.secondary
                                    : AppColors.textSecLight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.label.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.secondary
                                    : AppColors.textSecLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
