// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/data/services/insulin_service.dart';

/// İnsülin kaydı ekleme — tam ekran sayfa.
class InsulinEntryScreen extends StatefulWidget {
  final VoidCallback? onSaved;

  const InsulinEntryScreen({super.key, this.onSaved});

  @override
  State<InsulinEntryScreen> createState() => _InsulinEntryScreenState();
}

// ── Sabit listeler ────────────────────────────────────────────────────────────
const _kInsulinTypes = ['Hızlı etkili', 'Uzun etkili', 'Karma'];

const _kSites = ['Karın', 'Kol', 'Bacak', 'Kalça'];

const _kSiteIcons = {
  'Karın': Icons.circle_outlined,
  'Kol': Icons.accessibility_new_rounded,
  'Bacak': Icons.directions_walk_rounded,
  'Kalça': Icons.airline_seat_recline_normal_rounded,
};

class _InsulinEntryScreenState extends State<InsulinEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  final _noteController = TextEditingController();
  final _insulinService = InsulinService();

  String _selectedType = 'Hızlı etkili';
  String _selectedSite = 'Karın';
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _unitsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.secondary,
            onPrimary: Colors.white,
            surface: AppColors.surfaceLight,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final units = double.tryParse(
      _unitsController.text.trim().replaceAll(',', '.'),
    );
    if (units == null || units <= 0 || units > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir doz girin (0,1 – 100)'),
          backgroundColor: AppColors.tertiary,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final timestamp = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _insulinService.addInsulinLog(
        units: units,
        type: _selectedType,
        site: _selectedSite,
        timestamp: timestamp,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) return;
      widget.onSaved?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${units.toStringAsFixed(1)} ünite insülin kaydedildi'),
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: AppColors.secondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'İnsülin Kaydı',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              'Kaydet',
              style: AppTextStyles.label.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Zaman Seçici ───────────────────────────────────────
              _SectionTitle(title: 'Zaman', icon: Icons.access_time_rounded),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                        color: AppColors.secondary.withOpacity(0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.access_time_rounded,
                            color: AppColors.secondary, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saat',
                              style: AppTextStyles.label.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecLight)),
                          Text(
                            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.h1.copyWith(
                                fontSize: 26, color: AppColors.secondary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.secondary.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Enjeksiyon Bölgesi ────────────────────────────────
              _SectionTitle(
                  title: 'Enjeksiyon Bölgesi',
                  icon: Icons.location_on_rounded),
              const SizedBox(height: 10),
              Row(
                children: _kSites.map((site) {
                  final isSelected = _selectedSite == site;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSite = site),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.secondary.withOpacity(0.2),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _kSiteIcons[site] ?? Icons.circle_outlined,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.secondary,
                              size: 22,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              site,
                              style: AppTextStyles.label.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.secondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── İnsülin Tipi ──────────────────────────────────────
              _SectionTitle(
                  title: 'İnsülin Tipi', icon: Icons.vaccines_rounded),
              const SizedBox(height: 10),
              Row(
                children: _kInsulinTypes.map((type) {
                  final isSelected = _selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.secondary.withOpacity(0.2),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          type,
                          style: AppTextStyles.label.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Doz ───────────────────────────────────────────────
              _SectionTitle(
                  title: 'Doz (Ünite)', icon: Icons.colorize_rounded),
              const SizedBox(height: 10),
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
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.defaultRadius),
                    borderSide: BorderSide(
                        color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.defaultRadius),
                    borderSide: BorderSide(
                        color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.defaultRadius),
                    borderSide: const BorderSide(
                        color: AppColors.secondary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Doz girin';
                  final n = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (n == null || n <= 0 || n > 100) {
                    return '0,1 – 100 arası girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Not ───────────────────────────────────────────────
              _SectionTitle(
                  title: 'Not (isteğe bağlı)',
                  icon: Icons.sticky_note_2_outlined),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Örn: Öğle yemeği öncesi',
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.defaultRadius),
                    borderSide: BorderSide(
                        color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.defaultRadius),
                    borderSide: BorderSide(
                        color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.defaultRadius),
                    borderSide: const BorderSide(
                        color: AppColors.secondary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 36),

              // ── Kaydet Butonu ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Yardımcı widget ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
