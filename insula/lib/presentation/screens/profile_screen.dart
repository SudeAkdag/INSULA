import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

// Acil durum kişisi için model sınıfı
class EmergencyContact {
  final TextEditingController nameController;
  final TextEditingController phoneController;

  EmergencyContact({
    required this.nameController,
    required this.phoneController,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? _gender;
  DateTime? _dob;

  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();

  List<EmergencyContact> _emergencyContacts = [];

  static const double _cardRadius = 16;

  // ✅ Daha kompakt aralıklar
  static const double _gapXs = 4;
  static const double _gapSm = 8;
  static const double _gapMd = 10;
  static const double _sectionTop = 10;
  static const double _sectionBottom = 4;
  static const double _cardPadding = 12;
  static const double _cardMarginBottom = 8;

  bool _isLoading = true;
  String? _errorText;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _chronicCtrl.dispose();
    _allergyCtrl.dispose();
    for (var contact in _emergencyContacts) {
      contact.nameController.dispose();
      contact.phoneController.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorText = 'Oturum bulunamadı. Lütfen tekrar giriş yapın.';
          _isLoading = false;
        });
        return;
      }

      _emailCtrl.text = user.email ?? '';

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = doc.data()!;

      _nameCtrl.text = (data['fullName'] ?? '').toString();
      _emailCtrl.text = (data['email'] ?? _emailCtrl.text).toString();
      _gender = (data['gender'] as String?) ?? _gender;

      final bd = data['birthDate'];
      if (bd is Timestamp) _dob = bd.toDate();

      final h = data['height'];
      final w = data['weight'];
      if (h != null) _heightCtrl.text = (h as num).toString();
      if (w != null) _weightCtrl.text = (w as num).toString();

      _chronicCtrl.text = (data['chronicDiseases'] ?? '').toString();
      _allergyCtrl.text = (data['allergies'] ?? '').toString();

      final ec = data['emergencyContacts'];
      if (ec is List) {
        for (final c in _emergencyContacts) {
          c.nameController.dispose();
          c.phoneController.dispose();
        }
        _emergencyContacts = [];

        for (final item in ec) {
          if (item is Map) {
            _emergencyContacts.add(EmergencyContact(
              nameController:
                  TextEditingController(text: (item['name'] ?? '').toString()),
              phoneController:
                  TextEditingController(text: (item['phone'] ?? '').toString()),
            ));
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorText = 'Profil yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  void _addEmergencyContact() {
    setState(() {
      _emergencyContacts.add(EmergencyContact(
        nameController: TextEditingController(),
        phoneController: TextEditingController(),
      ));
    });
  }

  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts[index].nameController.dispose();
      _emergencyContacts[index].phoneController.dispose();
      _emergencyContacts.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorText = 'Oturum bulunamadı. Lütfen tekrar giriş yapın.';
          _isLoading = false;
        });
        return;
      }

      final height =
          double.tryParse(_heightCtrl.text.trim().replaceAll(',', '.'));
      final weight =
          double.tryParse(_weightCtrl.text.trim().replaceAll(',', '.'));

      if ((_heightCtrl.text.trim().isNotEmpty && height == null) ||
          (_weightCtrl.text.trim().isNotEmpty && weight == null)) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Boy/Kilo sayı olmalı. Örn: 175 / 70.5')),
        );
        return;
      }

      final ecList = _emergencyContacts.map((c) {
        return {
          'name': c.nameController.text.trim(),
          'phone': c.phoneController.text.trim(),
        };
      }).toList();

      await _firestore.collection('users').doc(user.uid).set({
        'fullName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'gender': _gender,
        'birthDate': _dob == null ? null : Timestamp.fromDate(_dob!),
        'height': height,
        'weight': weight,
        'chronicDiseases': _chronicCtrl.text.trim(),
        'allergies': _allergyCtrl.text.trim(),
        'emergencyContacts': ecList,
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil kaydedildi ✅')),
      );
    } catch (e) {
      setState(() {
        _errorText = 'Kaydederken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerName =
        _nameCtrl.text.trim().isEmpty ? 'Ad Soyad' : _nameCtrl.text.trim();
    final headerMail =
        _emailCtrl.text.trim().isEmpty ? 'E-posta' : _emailCtrl.text.trim();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil Ayarları',
          style: AppTextStyles.h1.copyWith(color: AppColors.secondary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: Text(
              'KAYDET',
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // ✅ daha kompakt
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileHeader(headerName, headerMail),

                  if (_errorText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.tertiary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        _errorText!,
                        style: AppTextStyles.body.copyWith(color: AppColors.tertiary),
                      ),
                    ),
                  ],

                  _section('Kişisel Bilgiler'),
                  _accentCard(
                    accent: AppColors.accentTeal,
                    child: Column(
                      children: [
                        _field('Ad Soyad', _nameCtrl, suffixIcon: Icons.person),
                        const SizedBox(height: _gapSm),
                        _field(
                          'E-posta',
                          _emailCtrl,
                          keyboard: TextInputType.emailAddress,
                          suffixIcon: Icons.email,
                          readOnly: true,
                        ),
                        const SizedBox(height: _gapSm),
                        Row(
                          children: [
                            Expanded(child: _genderField()),
                            const SizedBox(width: 12),
                            Expanded(child: _dobField()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _section('Fiziksel Ölçümler'),
                  _accentCard(
                    accent: AppColors.primary,
                    child: Row(
                      children: [
                        Expanded(
                          child: _field(
                            'Boy (cm)',
                            _heightCtrl,
                            hintText: 'Örn: 182',
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _field(
                            'Kilo (kg)',
                            _weightCtrl,
                            hintText: 'Örn: 78',
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _section('Sağlık Bilgileri'),
                  _accentCard(
                    accent: AppColors.primary,
                    child: Column(
                      children: [
                        _field('Kronik Hastalıklar', _chronicCtrl,
                            hintText: 'Örn: Tip 2 Diyabet'),
                        const SizedBox(height: _gapSm),
                        _field('Alerjiler', _allergyCtrl, hintText: 'Örn: Penisilin'),
                      ],
                    ),
                  ),

                  _section('Acil Durum Bilgisi', danger: true),
                  _accentCard(
                    accent: AppColors.tertiary,
                    child: Column(
                      children: [
                        ...List.generate(_emergencyContacts.length, (index) {
                          final contact = _emergencyContacts[index];
                          return Column(
                            children: [
                              if (index > 0) const SizedBox(height: _gapSm),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _field(
                                      'Ad Soyad',
                                      contact.nameController,
                                      hintText: 'Örn: Ayşe Yılmaz',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _field(
                                      'Telefon',
                                      contact.phoneController,
                                      keyboard: TextInputType.phone,
                                      hintText: 'Örn: +90 555 123 45 67',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: AppColors.tertiary,
                                      size: 24,
                                    ),
                                    onPressed: () => _removeEmergencyContact(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: _gapSm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _addEmergencyContact,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Kişi Ekle'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.tertiary,
                              side: BorderSide(color: AppColors.tertiary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.05),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _profileHeader(String headerName, String headerMail) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48, // ✅ 52 → 48 daha kompakt
                backgroundColor: AppColors.surfaceLight,
                child: Icon(Icons.person, size: 48, color: AppColors.secondary),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 16, // ✅ 18 → 16
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.camera_alt, size: 16, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _gapSm),
        Text(
          headerName,
          style: AppTextStyles.h1.copyWith(fontSize: 19),
        ),
        const SizedBox(height: 4),
        Text(
          headerMail,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecLight),
        ),
        const SizedBox(height: _gapMd), // ✅
      ],
    );
  }

  Widget _section(String title, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: _sectionTop, bottom: _sectionBottom),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.body.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: danger ? AppColors.tertiary : AppColors.accentTeal,
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType keyboard = TextInputType.text,
    String? hintText,
    IconData? suffixIcon,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: c,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
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
              borderSide: const BorderSide(color: AppColors.accentTeal, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // ✅
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.accentTeal, size: 22)
                : null,
          ),
          validator: (v) {
            if (label == 'Ad Soyad' && (v == null || v.trim().isEmpty)) {
              return 'Ad Soyad boş olamaz';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4), // ✅ 6 → 4
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.accentTeal,
        ),
      ),
    );
  }

  Widget _genderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Cinsiyet'),
        DropdownButtonFormField<String>(
          value: _gender,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Cinsiyet Seçiniz',
            hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.accentTeal, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // ✅
            suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.accentTeal, size: 22),
          ),
          items: const [
            DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
            DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
            DropdownMenuItem(value: 'Belirtmek İstemiyorum', child: Text('Belirtmek İstemiyorum')),
          ],
          onChanged: (v) => setState(() => _gender = v),
        ),
      ],
    );
  }

  Widget _dobField() {
    final text = _dob == null ? '' : _formatDate(_dob);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Doğum Tarihi'),
        InkWell(
          onTap: _isLoading ? null : _pickDob,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Örn: 15/05/1990',
              hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
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
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.accentTeal, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // ✅
              suffixIcon: Icon(Icons.calendar_today, color: AppColors.accentTeal, size: 22),
            ),
            child: Text(
              text.isEmpty ? 'Tarih seçiniz' : text,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: text.isEmpty ? Colors.grey : AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _accentCard({required Color accent, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(_cardPadding), // ✅ 16 → 14
      margin: const EdgeInsets.only(bottom: _cardMarginBottom), // ✅ 12 → 10
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border(left: BorderSide(color: accent, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}