class User {
  final String id;
  final String fullName;
  final String? profileImageUrl;
  final int dailyCarbGoal; 
  final double dailyWaterGoal;
  // Yeni: Şeker hedef aralığı (Gauge göstergesi için kritik)
  final int minTargetGlucose; 
  final int maxTargetGlucose;

  User({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    this.dailyCarbGoal = 200,
    this.dailyWaterGoal = 2.5,
    this.minTargetGlucose = 70,  // Varsayılan sağlıklı alt sınır
    this.maxTargetGlucose = 140, // Varsayılan sağlıklı üst sınır
  });
}