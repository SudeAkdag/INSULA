import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_personal_info_card.dart';
import '../widgets/profile/profile_physical_measurements_card.dart';
import '../widgets/profile/profile_health_info_card.dart';
import '../widgets/profile/profile_diabetes_profile_card.dart';
import '../widgets/profile/profile_treatment_tracking_card.dart';
import '../widgets/profile/profile_goals_lifestyle_card.dart';
import '../widgets/profile/profile_save_button.dart';
import 'profile_settings_screen.dart';

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
  final _ageCtrl = TextEditingController();

  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();
  final _allergyCtrl = TextEditingController();
  
  // New Onboarding Fields
  String? _diabetesType;
  final _diagnosisYearCtrl = TextEditingController();
  bool _usesInsulin = false;
  String? _insulinType;
  String? _insulinDeliveryMethod;
  bool _usesCgm = false;
  String? _glucoseMeasurementFrequency;
  final _targetMinCtrl = TextEditingController();
  final _targetMaxCtrl = TextEditingController();
  final _weeklyExerciseCtrl = TextEditingController();
  final _sleepHoursCtrl = TextEditingController();
  List<String> _improvementGoals = [];
  bool _hasSevereHypoHistory = false;
  bool _reminderMedication = false;
  bool _reminderMeasurement = false;
  bool _reminderWater = false;

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
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _chronicCtrl.dispose();
    _allergyCtrl.dispose();
    _diagnosisYearCtrl.dispose();
    _targetMinCtrl.dispose();
    _targetMaxCtrl.dispose();
    _weeklyExerciseCtrl.dispose();
    _sleepHoursCtrl.dispose();
    super.dispose();
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
      
      if (data['age'] != null) {
        _ageCtrl.text = data['age'].toString();
      }

      final bd = data['birthDate'];
      if (bd is Timestamp) _dob = bd.toDate();

      final h = data['height'];
      final w = data['weight'];
      if (h != null) _heightCtrl.text = (h as num).toString();
      if (w != null) _weightCtrl.text = (w as num).toString();

      _chronicCtrl.text = (data['chronicDiseases'] ?? '').toString();
      _allergyCtrl.text = (data['allergies'] ?? '').toString();

      // Load Onboarding Fields
      _diabetesType = data['diabetesType'] as String?;
      if (data['diagnosisYear'] != null) {
        _diagnosisYearCtrl.text = data['diagnosisYear'].toString();
      }
      _usesInsulin = data['usesInsulin'] as bool? ?? false;
      _insulinType = data['insulinType'] as String?;
      _insulinDeliveryMethod = data['insulinDeliveryMethod'] as String?;
      _usesCgm = data['usesCgm'] as bool? ?? false;
      _glucoseMeasurementFrequency = data['glucoseMeasurementFrequency'] as String?;
      
      if (data['targetGlucoseMin'] != null) {
        _targetMinCtrl.text = data['targetGlucoseMin'].toString();
      }
      if (data['targetGlucoseMax'] != null) {
        _targetMaxCtrl.text = data['targetGlucoseMax'].toString();
      }
      if (data['weeklyExerciseDays'] != null) {
        _weeklyExerciseCtrl.text = data['weeklyExerciseDays'].toString();
      }
      if (data['sleepHoursPerNight'] != null) {
        _sleepHoursCtrl.text = data['sleepHoursPerNight'].toString();
      }
      
      if (data['improvementGoals'] is List) {
        _improvementGoals = List<String>.from(data['improvementGoals']);
      }
      
      _hasSevereHypoHistory = data['hasSevereHypoglycemiaHistory'] as bool? ?? false;
      _reminderMedication = data['reminderMedication'] as bool? ?? false;
      _reminderMeasurement = data['reminderMeasurement'] as bool? ?? false;
      _reminderWater = data['reminderWater'] as bool? ?? false;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorText = 'Profil yüklenirken hata oluştu: $e';
        _isLoading = false;
      });
    }
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

      await _firestore.collection('users').doc(user.uid).set({
        'fullName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'gender': _gender,
        'age': int.tryParse(_ageCtrl.text.trim()),
        'birthDate': _dob == null ? null : Timestamp.fromDate(_dob!),
        'height': height,
        'weight': weight,
        'chronicDiseases': _chronicCtrl.text.trim(),
        'allergies': _allergyCtrl.text.trim(),

        // Save Onboarding Fields
        'diabetesType': _diabetesType,
        'diagnosisYear': int.tryParse(_diagnosisYearCtrl.text.trim()),
        'usesInsulin': _usesInsulin,
        'insulinType': _insulinType,
        'insulinDeliveryMethod': _insulinDeliveryMethod,
        'usesCgm': _usesCgm,
        'glucoseMeasurementFrequency': _glucoseMeasurementFrequency,
        'targetGlucoseMin': int.tryParse(_targetMinCtrl.text.trim()),
        'targetGlucoseMax': int.tryParse(_targetMaxCtrl.text.trim()),
        'weeklyExerciseDays': int.tryParse(_weeklyExerciseCtrl.text.trim()),
        'sleepHoursPerNight': double.tryParse(_sleepHoursCtrl.text.trim().replaceAll(',', '.')),
        'improvementGoals': _improvementGoals,
        'hasSevereHypoglycemiaHistory': _hasSevereHypoHistory,
        'reminderMedication': _reminderMedication,
        'reminderMeasurement': _reminderMeasurement,
        'reminderWater': _reminderWater,

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
          'Profil ',
          style: AppTextStyles.h1.copyWith(color: AppColors.secondary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.secondary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSettingsScreen(
                    initialHasSevereHypoHistory: _hasSevereHypoHistory,
                    initialReminderMedication: _reminderMedication,
                    initialReminderMeasurement: _reminderMeasurement,
                    initialReminderWater: _reminderWater,
                  ),
                ),
              );

              if (result != null && result is Map<String, bool>) {
                setState(() {
                  _hasSevereHypoHistory = result['hasSevereHypoHistory'] ?? _hasSevereHypoHistory;
                  _reminderMedication = result['reminderMedication'] ?? _reminderMedication;
                  _reminderMeasurement = result['reminderMeasurement'] ?? _reminderMeasurement;
                  _reminderWater = result['reminderWater'] ?? _reminderWater;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), // ✅ Breathable padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    name: _nameCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                  ),

                  if (_errorText != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.tertiary.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        _errorText!,
                        style: AppTextStyles.body.copyWith(color: AppColors.tertiary),
                      ),
                    ),
                  ],

                  ProfilePersonalInfoCard(
                    nameController: _nameCtrl,
                    emailController: _emailCtrl,
                    ageController: _ageCtrl,
                    gender: _gender,
                    dob: _dob,
                    onPickDob: _pickDob,
                    onGenderChanged: (v) => setState(() => _gender = v),
                  ),

                  ProfilePhysicalMeasurementsCard(
                    heightController: _heightCtrl,
                    weightController: _weightCtrl,
                  ),

                  ProfileHealthInfoCard(
                    chronicCtrl: _chronicCtrl,
                    allergyCtrl: _allergyCtrl,
                  ),

                  ProfileDiabetesProfileCard(
                    diabetesType: _diabetesType,
                    diagnosisYearCtrl: _diagnosisYearCtrl,
                    onDiabetesTypeChanged: (v) => setState(() => _diabetesType = v),
                  ),

                  ProfileTreatmentTrackingCard(
                    usesInsulin: _usesInsulin,
                    insulinType: _insulinType,
                    insulinDeliveryMethod: _insulinDeliveryMethod,
                    usesCgm: _usesCgm,
                    glucoseMeasurementFrequency: _glucoseMeasurementFrequency,
                    onUsesInsulinChanged: (v) => setState(() => _usesInsulin = v),
                    onInsulinTypeChanged: (v) => setState(() => _insulinType = v),
                    onInsulinMethodChanged: (v) => setState(() => _insulinDeliveryMethod = v),
                    onUsesCgmChanged: (v) => setState(() => _usesCgm = v),
                    onFrequencyChanged: (v) => setState(() => _glucoseMeasurementFrequency = v),
                  ),

                  ProfileGoalsLifestyleCard(
                    targetMinCtrl: _targetMinCtrl,
                    targetMaxCtrl: _targetMaxCtrl,
                    weeklyExerciseCtrl: _weeklyExerciseCtrl,
                    sleepHoursCtrl: _sleepHoursCtrl,
                    improvementGoals: _improvementGoals,
                    onGoalsChanged: (v) => setState(() => _improvementGoals = v),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.05),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ProfileSaveButton(
            onPressed: _save,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }

}
