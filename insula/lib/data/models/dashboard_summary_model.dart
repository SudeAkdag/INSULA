class DashboardSummary {
  final int steps;            // HTML: 4,200
  final double currentCarbs;  // HTML: 45g
  final int insulinUnits;     // HTML: 12Ü
  final double sleepHours;    // HTML: 7.5s
  final double currentWater;  // HTML: 1.2 Litre

  DashboardSummary({
    required this.steps,
    required this.currentCarbs,
    required this.insulinUnits,
    required this.sleepHours,
    required this.currentWater,
  });

  // İlerleme yüzdesini hesaplayan yardımcı fonksiyon (Su barı için)
  double waterProgress(double goal) => (currentWater / goal).clamp(0.0, 1.0);
}