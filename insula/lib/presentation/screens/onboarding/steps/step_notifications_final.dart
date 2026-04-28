import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_input_card.dart';

class StepNotificationsFinal extends StatefulWidget {
  const StepNotificationsFinal({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onComplete,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onComplete;

  @override
  State<StepNotificationsFinal> createState() => _StepNotificationsFinalState();
}

class _StepNotificationsFinalState extends State<StepNotificationsFinal> {
  bool _reminderMedication = true;
  bool _reminderMeasurement = true;
  bool _reminderWater = true;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _reminderMedication = widget.data.reminderMedication ?? true;
    _reminderMeasurement = widget.data.reminderMeasurement ?? true;
    _reminderWater = widget.data.reminderWater ?? true;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      reminderMedication: _reminderMedication,
      reminderMeasurement: _reminderMeasurement,
      reminderWater: _reminderWater,
      password: _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim(),
    ));
  }

  bool get _canComplete {
    final p = _passwordController.text.trim();
    final c = _confirmPasswordController.text.trim();
    // En az 8 karakter, 1 büyük harf, 1 rakam
    final hasMinLength = p.length >= 8;
    final hasUppercase = p.contains(RegExp(r'[A-Z]'));
    final hasDigit = p.contains(RegExp(r'[0-9]'));
    return hasMinLength && hasUppercase && hasDigit && p == c;
  }

  // Şifre güç seviyesi (0=zayıf, 1=orta, 2=güçlü)
  int get _passwordStrength {
    final p = _passwordController.text.trim();
    if (p.length < 8) return 0;
    int score = 0;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    if (score >= 3) return 2;
    if (score >= 1) return 1;
    return 0;
  }

  String? get _passwordError {
    final p = _passwordController.text.trim();
    if (p.isEmpty) return null;
    if (p.length < 8) return 'Şifre en az 8 karakter olmalıdır';
    if (!p.contains(RegExp(r'[A-Z]'))) return 'En az 1 büyük harf içermelidir';
    if (!p.contains(RegExp(r'[0-9]'))) return 'En az 1 rakam içermelidir';
    return null;
  }

  String? get _confirmError {
    final p = _passwordController.text.trim();
    final c = _confirmPasswordController.text.trim();
    if (c.isEmpty) return null;
    if (p != c) return 'Şifreler eşleşmiyor';
    return null;
  }

  // Yardımcı hata widget'ı
  Widget _errorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 13, color: Colors.red.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bildirimler ve Hesap',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hatırlatıcı tercihlerinizi seçin ve hesabınızı oluşturmak için bir şifre belirleyin.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Hatırlatıcılar',
            style: AppTextStyles.label
                .copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ReminderTile(
            title: 'İlaç hatırlatıcı',
            icon: Icons.medication_outlined,
            value: _reminderMedication,
            onChanged: (v) {
              setState(() {
                _reminderMedication = v;
                _emit();
              });
            },
          ),
          _ReminderTile(
            title: 'Ölçüm hatırlatıcı',
            icon: Icons.bloodtype_outlined,
            value: _reminderMeasurement,
            onChanged: (v) {
              setState(() {
                _reminderMeasurement = v;
                _emit();
              });
            },
          ),
          _ReminderTile(
            title: 'Su içme hatırlatıcı',
            icon: Icons.water_drop_outlined,
            value: _reminderWater,
            onChanged: (v) {
              setState(() {
                _reminderWater = v;
                _emit();
              });
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Hesap şifresi',
            style: AppTextStyles.label
                .copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          OnboardingInputCard(
            icon: Icons.lock_outline,
            hasError: _passwordError != null,
            child: TextField(
              controller: _passwordController,
              onChanged: (_) => setState(() {
                _emit();
              }),
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'En az 8 karakter, 1 büyük harf, 1 rakam',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecLight,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
          ),
          // -- Şifre güç göstergesi --
          Builder(builder: (context) {
            final strength = _passwordStrength;
            final p = _passwordController.text.trim();
            final colors = [
              Colors.red.shade400,
              Colors.orange.shade400,
              Colors.green.shade500,
            ];
            final labels = ['Zayıf', 'Orta', 'Güçlü'];
            return p.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(left: 4, top: 6, bottom: 2),
                    child: Row(
                      children: [
                        ...List.generate(3, (i) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 4,
                                decoration: BoxDecoration(
                                  color: i <= strength
                                      ? colors[strength]
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          labels[strength],
                          style: TextStyle(
                            fontSize: 12,
                            color: colors[strength],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
          }),
          _errorText(_passwordError),
          const SizedBox(height: AppSpacing.md),
          OnboardingInputCard(
            icon: Icons.lock_outline,
            hasError: _confirmError != null,
            child: TextField(
              controller: _confirmPasswordController,
              onChanged: (_) => setState(() {}),
              obscureText: _obscureConfirm,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Şifre tekrar',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 16),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecLight,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
          ),
          _errorText(_confirmError),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _canComplete
                  ? () {
                      _emit();
                      widget.onComplete();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
              ),
              child: const Text(
                "Insula'yı Başlat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          title: Row(
            children: [
              Icon(icon, color: AppColors.secondary, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTextStyles.body.copyWith(fontSize: 16)),
            ],
          ),
          activeThumbColor: AppColors.secondary,
        ),
      ),
    );
  }
}
