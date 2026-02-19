import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Acil durum kişileri için dinamik liste
  List<EmergencyContact> _emergencyContacts = [];

  static const double _cardRadius = 16;

  @override
  void initState() {
    super.initState();
    _dob = DateTime.now(); // Bugünün tarihi varsayılan olarak seçili
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
                    _field('Ad Soyad', _nameCtrl, suffixIcon: Icons.person),
                    const SizedBox(height: 16),
                    _field(
                      'E-posta',
                      _emailCtrl,
                      keyboard: TextInputType.emailAddress,
                      suffixIcon: Icons.email,
                    ),
                    const SizedBox(height: 16),
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
                    Expanded(child: _field('Boy (cm)', _heightCtrl, hintText: 'Örn: 182')),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Kilo (kg)', _weightCtrl, hintText: 'Örn: 78')),
                  ],
                ),
              ),

              _section('Sağlık Bilgileri'),
              _accentCard(
                accent: AppColors.primary,
                child: Column(
                  children: [
                    _field('Kronik Hastalıklar', _chronicCtrl, hintText: 'Örn: Tip 2 Diyabet'),
                    const SizedBox(height: 16),
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
                          if (index > 0) const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addEmergencyContact,
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
        Text(
          'Ad Soyad',
          style: AppTextStyles.h1.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          'E-posta',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecLight),
        ),
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
    String? hintText,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: c,
          keyboardType: keyboard,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.accentTeal, size: 22)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.accentTeal, size: 22),
          ),
          items: const [
            DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
            DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
            DropdownMenuItem(
              value: 'Belirtmek İstemiyorum',
              child: Text('Belirtmek İstemiyorum'),
            ),
          ],
          onChanged: (v) => setState(() => _gender = v),
        ),
      ],
    );
  }

  Widget _dobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Doğum Tarihi'),
        InkWell(
          onTap: _pickDob,
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: Icon(Icons.calendar_today, color: AppColors.accentTeal, size: 22),
            ),
            child: Text(
              '', // Her zaman boş göster, hint text görünsün
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
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

}
