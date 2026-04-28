import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_input_card.dart';

// --- Yardımcı Formatter: Harf + en fazla 1 boşluk ---
class _NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Ardışık boşlukları engelle
    if (text.contains('  ')) return oldValue;

    // İzin verilen karakterler: Türkçe harfler ve tek boşluk
    final regex = RegExp(r"[a-zA-ZçÇğĞıİöÖşŞüÜ ]");
    final filtered = text.split('').where((c) => regex.hasMatch(c)).join();
    if (filtered != text) return oldValue;

    return newValue;
  }
}

class StepBasicInfo extends StatefulWidget {
  const StepBasicInfo({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends State<StepBasicInfo> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // Hata mesajları
  String? _nameError;
  String? _emailError;
  String? _heightError;
  String? _weightError;

  static const _genders = ['Erkek', 'Kadın', 'Diğer'];
  String _gender = 'Erkek';
  DateTime? _birthDate;

  // Türkçe harf + boşluk regex (başlangıç/bitiş trim sonrası tam eşleşme)
  static final _nameRegex =
      RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ]+(?: [a-zA-ZçÇğĞıİöÖşŞüÜ]+)+$');
  static final _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.data.fullName ?? '';
    _emailController.text = widget.data.email ?? '';
    if (widget.data.heightCm != null) {
      _heightController.text = widget.data.heightCm!.toInt().toString();
    }
    if (widget.data.weightKg != null) {
      _weightController.text = widget.data.weightKg!.toInt().toString();
    }
    _gender = widget.data.gender ?? _genders[0];
    _birthDate = widget.data.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _emit() {
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    widget.onChanged(widget.data.copyWith(
      fullName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      birthDate: _birthDate,
      heightCm: height,
      weightKg: weight,
      gender: _gender,
    ));
  }

  // --- Validasyon fonksiyonları ---
  void _validateName(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _nameError = 'Ad Soyad zorunludur';
      } else if (!_nameRegex.hasMatch(trimmed)) {
        _nameError = 'Lütfen yalnızca harf kullanın (örn. Ayşe Demir)';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _emailError = 'E-posta zorunludur';
      } else if (!_emailRegex.hasMatch(trimmed)) {
        _emailError = 'Geçerli bir e-posta girin (örn. ad@alan.com)';
      } else {
        _emailError = null;
      }
    });
  }

  void _validateHeight(String value) {
    final trimmed = value.trim();
    final height = int.tryParse(trimmed);
    setState(() {
      if (trimmed.isEmpty) {
        _heightError = 'Boy zorunludur';
      } else if (height == null || height < 50 || height > 250) {
        _heightError = '50–250 cm arasında olmalıdır';
      } else {
        _heightError = null;
      }
    });
  }

  void _validateWeight(String value) {
    final trimmed = value.trim();
    final weight = int.tryParse(trimmed);
    setState(() {
      if (trimmed.isEmpty) {
        _weightError = 'Kilo zorunludur';
      } else if (weight == null || weight < 10 || weight > 300) {
        _weightError = '10–300 kg arasında olmalıdır';
      } else {
        _weightError = null;
      }
    });
  }

  bool get _canNext {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final height = int.tryParse(_heightController.text.trim());
    final weight = int.tryParse(_weightController.text.trim());

    return _nameRegex.hasMatch(name) &&
        _emailRegex.hasMatch(email) &&
        _birthDate != null &&
        (height != null && height >= 50 && height <= 250) &&
        (weight != null && weight >= 10 && weight <= 300) &&
        _nameError == null &&
        _emailError == null &&
        _heightError == null &&
        _weightError == null;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _emit();
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Hata mesajı widget'ı
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
            'Temel Bilgiler',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Size daha iyi hizmet verebilmemiz için birkaç bilgiye ihtiyacımız var.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // -- Ad Soyad --
          OnboardingInputCard(
            icon: Icons.person_outline,
            label: 'Ad Soyad',
            hasError: _nameError != null,
            child: TextField(
              controller: _nameController,
              inputFormatters: [
                _NameInputFormatter(),
                LengthLimitingTextInputFormatter(50),
              ],
              onChanged: (v) {
                _validateName(v);
                _emit();
              },
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Adınız ve soyadınız',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          _errorText(_nameError),
          const SizedBox(height: AppSpacing.md),

          // -- E-posta --
          OnboardingInputCard(
            icon: Icons.email_outlined,
            label: 'E-posta',
            hasError: _emailError != null,
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) {
                _validateEmail(v);
                _emit();
              },
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'ornek@email.com',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          _errorText(_emailError),
          const SizedBox(height: AppSpacing.md),

          // -- Doğum Tarihi DatePicker --
          OnboardingInputCard(
            icon: Icons.cake_outlined,
            label: 'Doğum Tarihi',
            child: InkWell(
              onTap: _pickBirthDate,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _birthDate != null
                            ? _formatDate(_birthDate!)
                            : 'Tarih seçin',
                        style: TextStyle(
                          fontSize: 18,
                          color: _birthDate != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month_outlined,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // -- Boy & Kilo --
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OnboardingInputCard(
                      icon: Icons.height,
                      label: 'Boy (cm)',
                      hasError: _heightError != null,
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onChanged: (v) {
                          _validateHeight(v);
                          _emit();
                        },
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: '175',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: 16),
                        ),
                      ),
                    ),
                    _errorText(_heightError),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OnboardingInputCard(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Kilo (kg)',
                      hasError: _weightError != null,
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onChanged: (v) {
                          _validateWeight(v);
                          _emit();
                        },
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: '70',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: 16),
                        ),
                      ),
                    ),
                    _errorText(_weightError),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Cinsiyet',
            style: AppTextStyles.label
                .copyWith(fontSize: 15, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: _genders.map((g) {
              final selected = _gender == g;
              return Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: g != _genders.last ? AppSpacing.sm : 0),
                  child: Material(
                    color: selected
                        ? AppColors.secondary.withAlpha(26)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _gender = g;
                          _emit();
                        });
                      },
                      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            g,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? AppColors.secondary
                                  : AppColors.textSecLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _canNext
                  ? () {
                      _emit();
                      widget.onNext();
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
              child: const Text('Devam',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
