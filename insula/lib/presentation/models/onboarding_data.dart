/// Onboarding akışında toplanan tüm veriler.
/// Firestore'a kaydedilecek alanlarla uyumludur.
class OnboardingData {
  OnboardingData({
    this.fullName,
    this.email,
    this.password,
    this.age,
    this.heightCm,
    this.weightKg,
    this.gender,
    this.diabetesType,
    this.diagnosisYear,
    this.usesInsulin,
    this.insulinType,
    this.insulinDeliveryMethod,
    this.carbRatio,
    this.glucoseMeasurementFrequency,
    this.usesCgm,
    this.targetGlucoseMin,
    this.targetGlucoseMax,
    this.weeklyExerciseDays,
    this.sleepHoursPerNight,
    this.improvementGoals,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.hasSevereHypoglycemiaHistory,
    this.reminderMedication,
    this.reminderMeasurement,
    this.reminderWater,
  });

  // Temel bilgiler
  String? fullName;
  String? email;
  String? password;
  int? age;
  double? heightCm;
  double? weightKg;
  String? gender;

  // Diyabet profili
  String? diabetesType; // Tip 1, Tip 2, Gestasyonel, Prediyabet
  int? diagnosisYear;

  // Tedavi (adaptif)
  bool? usesInsulin;
  String? insulinType; // Hızlı, Uzun etkili, Karma
  String? insulinDeliveryMethod; // Kalem, Pompa
  int? carbRatio; // 1 ünite insülin / X g karbonhidrat (örn: 10 = 1:10)

  // Glikoz izleme
  String? glucoseMeasurementFrequency; // Günlük ölçüm sıklığı
  bool? usesCgm;
  int? targetGlucoseMin;
  int? targetGlucoseMax;

  // Yaşam tarzı ve hedefler
  int? weeklyExerciseDays;
  double? sleepHoursPerNight;
  List<String>? improvementGoals;

  // Acil durum ve güvenlik
  String? emergencyContactName;
  String? emergencyContactPhone;
  bool? hasSevereHypoglycemiaHistory;

  // Bildirimler
  bool? reminderMedication;
  bool? reminderMeasurement;
  bool? reminderWater;

  OnboardingData copyWith({
    String? fullName,
    String? email,
    String? password,
    int? age,
    double? heightCm,
    double? weightKg,
    String? gender,
    String? diabetesType,
    int? diagnosisYear,
    bool? usesInsulin,
    String? insulinType,
    String? insulinDeliveryMethod,
    int? carbRatio,
    String? glucoseMeasurementFrequency,
    bool? usesCgm,
    int? targetGlucoseMin,
    int? targetGlucoseMax,
    int? weeklyExerciseDays,
    double? sleepHoursPerNight,
    List<String>? improvementGoals,
    String? emergencyContactName,
    String? emergencyContactPhone,
    bool? hasSevereHypoglycemiaHistory,
    bool? reminderMedication,
    bool? reminderMeasurement,
    bool? reminderWater,
  }) {
    return OnboardingData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      diabetesType: diabetesType ?? this.diabetesType,
      diagnosisYear: diagnosisYear ?? this.diagnosisYear,
      usesInsulin: usesInsulin ?? this.usesInsulin,
      insulinType: insulinType ?? this.insulinType,
      insulinDeliveryMethod: insulinDeliveryMethod ?? this.insulinDeliveryMethod,
      carbRatio: carbRatio ?? this.carbRatio,
      glucoseMeasurementFrequency:
          glucoseMeasurementFrequency ?? this.glucoseMeasurementFrequency,
      usesCgm: usesCgm ?? this.usesCgm,
      targetGlucoseMin: targetGlucoseMin ?? this.targetGlucoseMin,
      targetGlucoseMax: targetGlucoseMax ?? this.targetGlucoseMax,
      weeklyExerciseDays: weeklyExerciseDays ?? this.weeklyExerciseDays,
      sleepHoursPerNight: sleepHoursPerNight ?? this.sleepHoursPerNight,
      improvementGoals: improvementGoals ?? this.improvementGoals,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      hasSevereHypoglycemiaHistory:
          hasSevereHypoglycemiaHistory ?? this.hasSevereHypoglycemiaHistory,
      reminderMedication: reminderMedication ?? this.reminderMedication,
      reminderMeasurement: reminderMeasurement ?? this.reminderMeasurement,
      reminderWater: reminderWater ?? this.reminderWater,
    );
  }

  /// Firestore için Map (merge için kullanılır).
  Map<String, dynamic> toFirestoreMap() {
    final map = <String, String?>{
      'fullName': fullName,
      'email': email,
      'gender': gender,
      'diabetesType': diabetesType,
      'insulinType': insulinType,
      'insulinDeliveryMethod': insulinDeliveryMethod,
      'glucoseMeasurementFrequency': glucoseMeasurementFrequency,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    };
    final out = <String, dynamic>{};
    for (final e in map.entries) {
      if (e.value != null && e.value!.isNotEmpty) out[e.key] = e.value;
    }
    if (age != null) out['age'] = age;
    if (heightCm != null) out['height'] = heightCm;
    if (weightKg != null) out['weight'] = weightKg;
    if (diagnosisYear != null) out['diagnosisYear'] = diagnosisYear;
    if (usesInsulin != null) out['usesInsulin'] = usesInsulin;
    if (carbRatio != null) out['carbRatio'] = carbRatio;
    if (usesCgm != null) out['usesCgm'] = usesCgm;
    if (targetGlucoseMin != null) out['targetGlucoseMin'] = targetGlucoseMin;
    if (targetGlucoseMax != null) out['targetGlucoseMax'] = targetGlucoseMax;
    if (weeklyExerciseDays != null) out['weeklyExerciseDays'] = weeklyExerciseDays;
    if (sleepHoursPerNight != null) out['sleepHoursPerNight'] = sleepHoursPerNight;
    if (improvementGoals != null && improvementGoals!.isNotEmpty) {
      out['improvementGoals'] = improvementGoals;
    }
    if (hasSevereHypoglycemiaHistory != null) {
      out['hasSevereHypoglycemiaHistory'] = hasSevereHypoglycemiaHistory;
    }
    if (reminderMedication != null) out['reminderMedication'] = reminderMedication;
    if (reminderMeasurement != null) out['reminderMeasurement'] = reminderMeasurement;
    if (reminderWater != null) out['reminderWater'] = reminderWater;
    out['profileComplete'] = true;
    return out;
  }
}
