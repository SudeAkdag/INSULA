import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/profile/settings/profile_security_notifications_card.dart';
import '../widgets/profile/settings/profile_app_preferences_card.dart';
import '../widgets/profile/settings/profile_account_actions_card.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final bool initialHasSevereHypoHistory;
  final bool initialReminderMedication;
  final bool initialReminderMeasurement;
  final bool initialReminderWater;

  const ProfileSettingsScreen({
    super.key,
    required this.initialHasSevereHypoHistory,
    required this.initialReminderMedication,
    required this.initialReminderMeasurement,
    required this.initialReminderWater,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late bool _hasSevereHypoHistory;
  late bool _reminderMedication;
  late bool _reminderMeasurement;
  late bool _reminderWater;
  
  String _selectedLanguage = 'Türkçe';
  
  bool _isLoading = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _hasSevereHypoHistory = widget.initialHasSevereHypoHistory;
    _reminderMedication = widget.initialReminderMedication;
    _reminderMeasurement = widget.initialReminderMeasurement;
    _reminderWater = widget.initialReminderWater;
    _loadExtraSettings();
  }

  Future<void> _loadExtraSettings() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _selectedLanguage = data['language'] ?? 'Türkçe';
          });
        }
      }
    } catch (e) {
      debugPrint('Ek ayarlar yüklenirken hata: $e');
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'hasSevereHypoglycemiaHistory': _hasSevereHypoHistory,
          'reminderMedication': _reminderMedication,
          'reminderMeasurement': _reminderMeasurement,
          'reminderWater': _reminderWater,
          'language': _selectedLanguage,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ayarlar kaydedildi ✅')),
        );
        Navigator.pop(context, {
          'hasSevereHypoHistory': _hasSevereHypoHistory,
          'reminderMedication': _reminderMedication,
          'reminderMeasurement': _reminderMeasurement,
          'reminderWater': _reminderWater,
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydedilirken hata oluştu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Oturumu Kapat'),
        content: const Text('Oturumu sonlandırmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _auth.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
          style: TextStyle(color: Colors.red),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                final user = _auth.currentUser;
                if (user != null) {
                  // Firestore verilerini sil
                  await _firestore.collection('users').doc(user.uid).delete();
                  // Kullanıcıyı sil
                  await user.delete();
                  if (mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e. Lütfen tekrar giriş yapıp deneyin.')),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
          'Uygulama Ayarları',
          style: AppTextStyles.h1.copyWith(color: AppColors.secondary),
        ),
        centerTitle: true,
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            : TextButton(
                onPressed: _saveSettings,
                child: Text(
                  'Kaydet',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.accentTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ProfileSecurityNotificationsCard(
              hasSevereHypoHistory: _hasSevereHypoHistory,
              reminderMedication: _reminderMedication,
              reminderMeasurement: _reminderMeasurement,
              reminderWater: _reminderWater,
              onHypoHistoryChanged: (v) => setState(() => _hasSevereHypoHistory = v),
              onMedicationReminderChanged: (v) => setState(() => _reminderMedication = v),
              onMeasurementReminderChanged: (v) => setState(() => _reminderMeasurement = v),
              onWaterReminderChanged: (v) => setState(() => _reminderWater = v),
            ),
            const SizedBox(height: 8),
            ProfileAppPreferencesCard(
              language: _selectedLanguage,
              onLanguageChanged: (v) => setState(() => _selectedLanguage = v ?? 'Türkçe'),
            ),
            const SizedBox(height: 8),
            ProfileAccountActionsCard(
              onLogout: _handleLogout,
              onDeleteAccount: _handleDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
