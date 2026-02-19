import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController(text: 'Ahmet Yılmaz');
  final _emailCtrl = TextEditingController(text: 'ahmet.yilmaz@email.com');

  String _gender = 'Erkek';
  DateTime? _dob = DateTime(1990, 5, 15);

  final _heightCtrl = TextEditingController(text: '182');
  final _weightCtrl = TextEditingController(text: '78');
  final _chronicCtrl = TextEditingController(text: 'Tip 2 Diyabet');
  final _allergyCtrl = TextEditingController(text: 'Penisilin, Yer fıstığı');
  final _emergencyNameCtrl =
      TextEditingController(text: 'Ayşe Yılmaz (Eş)');
  final _emergencyPhoneCtrl =
      TextEditingController(text: '+90 555 123 45 67');

  static const double _cardRadius = 16;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _chronicCtrl.dispose();
    _allergyCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
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
      initialDate: _dob ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil kaydedildi')),
      );
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
            onPressed: _save,
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _profileHeader(),

              _section('Kişisel Bilgiler'),
              _accentCard(
                accent: AppColors.accentTeal,
                child: Column(
                  children: [
                    _field('Ad Soyad', _nameCtrl),
                    const SizedBox(height: 12),
                    _field(
                      'E-posta',
                      _emailCtrl,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
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
                    Expanded(child: _field('Boy (cm)', _heightCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Kilo (kg)', _weightCtrl)),
                  ],
                ),
              ),

              _section('Sağlık Bilgileri'),
              _accentCard(
                accent: AppColors.primary,
                child: Column(
                  children: [
                    _field('Kronik Hastalıklar', _chronicCtrl),
                    const SizedBox(height: 12),
                    _field('Alerjiler', _allergyCtrl),
                  ],
                ),
              ),

              _section('Acil Durum Bilgisi', danger: true),
              _accentCard(
                accent: AppColors.tertiary,
                child: Column(
                  children: [
                    _field('Acil Kişi', _emergencyNameCtrl),
                    const SizedBox(height: 12),
                    _field(
                      'Telefon',
                      _emergencyPhoneCtrl,
                      keyboard: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _profileHeader() {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: AppColors.surfaceLight,
                child: Icon(Icons.person,
                    size: 56, color: AppColors.secondary),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.camera_alt,
                      size: 18, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(_nameCtrl.text,
            style: AppTextStyles.h1.copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(_emailCtrl.text,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecLight)),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _section(String title, {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
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
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboard,
      style: AppTextStyles.body,
      decoration: _inputDecoration(label),
    );
  }

  Widget _genderField() {
    return DropdownButtonFormField<String>(
      value: _gender,
      isExpanded: true, // 🔴 OVERFLOW FIX
      decoration: _inputDecoration('Cinsiyet'),
      items: const [
        DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
        DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
        DropdownMenuItem(
          value: 'Belirtmek İstemiyorum',
          child: Text('Belirtmek İstemiyorum'),
        ),
      ],
      onChanged: (v) => setState(() => _gender = v ?? _gender),
    );
  }

  Widget _dobField() {
    return InkWell(
      onTap: _pickDob,
      child: InputDecorator(
        decoration: _inputDecoration('Doğum Tarihi'),
        child: Text(
          _formatDate(_dob),
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body,
        ),
      ),
    );
  }

  Widget _accentCard({required Color accent, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label.toUpperCase(),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: AppTextStyles.body.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.accentTeal,
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
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentTeal, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
