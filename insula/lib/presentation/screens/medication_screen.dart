// İlaç Takip sayfası: Günlük ilaç listesi, takvim gün seçimi, ilerleme kartı
// ve Sabah/Öğle/Akşam bölümlerinde ilaç kartlarını gösterir. Widget'lar
// presentation/widgets/medication/ altındaki ayrı dosyalardan import edilir.
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/medication/medication_progress_card.dart';
import '../widgets/medication/medication_section.dart';
import '../widgets/medication/medication_card_data.dart';
import 'add_medication_screen.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication, color: AppColors.accentTeal, size: 24),
            const SizedBox(width: 8),
            Text("İlaç Takip", style: AppTextStyles.h1),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: null, // UI-only
            child: Text(
              'Düzenle',
              style: AppTextStyles.body.copyWith(
                color: AppColors.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MedicationProgressCard(
            selectedDate: _selectedDate ?? DateTime.now(),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const SizedBox(height: 24),
          MedicationSection(
            title: 'Sabah',
            medications: [
              MedicationCardData(
                name: 'Insulin Aspart',
                dosage: '10 Ünite',
                time: '08:00',
                icon: Icons.medication_liquid,
                iconColor: Colors.lightBlue,
                dosageColor: Colors.blue,
                isTaken: true,
              ),
              MedicationCardData(
                name: 'Diamicron',
                dosage: '60 mg',
                time: '06:30',
                icon: Icons.medication,
                iconColor: Colors.red.shade300,
                dosageColor: Colors.red,
                isTaken: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          MedicationSection(
            title: 'Öğle',
            medications: [
              MedicationCardData(
                name: 'Metformin',
                dosage: '1000 mg',
                time: '13:00',
                icon: Icons.medication,
                iconColor: Colors.red.shade300,
                dosageColor: Colors.red,
                isTaken: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          MedicationSection(
            title: 'Akşam',
            medications: [
              MedicationCardData(
                name: 'Insulin Glargine',
                dosage: '24 Ünite',
                time: '20:00',
                icon: Icons.medication_liquid,
                iconColor: Colors.lightBlue,
                dosageColor: Colors.blue,
                isTaken: false,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFFFC107),
        elevation: 4,
        icon: const Icon(
          Icons.add,
          color: AppColors.secondary,
          size: 24,
        ),
        label: Text(
          "İlaç Ekle",
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
