enum MedicationType { pill, injection }

class Medication {
  final String name;      // Örn: "Insulin Aspart"
  final String dosage;    // Örn: "10 Ünite" veya "60 mg"
  final String? time;      
  final MedicationType? type;
  final String? form;
  final List<String>? searchKeywords;
  bool isTaken;

  Medication({
    required this.name,
    required this.dosage,
    this.time,
    this.type,
    this.form,
    this.searchKeywords,
    this.isTaken = false,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: (json['name'] ?? "") as String,
      dosage: (json['dose'] ?? "") as String,
      form: (json['form'] ?? "") as String,
      searchKeywords: json['searchKeywords'] != null
          ? List<String>.from(json['searchKeywords'] as List)
          : [],
    );
  }
}