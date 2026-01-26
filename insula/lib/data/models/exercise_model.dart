class Exercise {
  final String title;        // Örn: "Sabah Yürüyüşü"
  final int durationMinutes; // Örn: 30
  final String intensity;    // Örn: "Orta Yoğunluk"
  final int caloriesBurned;  // Örn: 300

  Exercise({
    required this.title,
    required this.durationMinutes,
    required this.intensity,
    required this.caloriesBurned,
  });
}