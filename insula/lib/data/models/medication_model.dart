enum MedicationType { pill, injection }

class Medication {
  final String name;      // Örn: "Insulin Aspart"
  final String dosage;    // Örn: "10 Ünite" veya "60 mg"
  final String time;      // Örn: "08:00"
  final MedicationType type;
  bool isTaken;

  Medication({
    required this.name,
    required this.dosage,
    required this.time,
    required this.type,
    this.isTaken = false,
  });
}