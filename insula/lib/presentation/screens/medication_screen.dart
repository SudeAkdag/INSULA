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
  List<Map<String, dynamic>> _savedMedications = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  List<MedicationCardData> _getMedicationsForSection(String usageTime) {
    final medications = <MedicationCardData>[];
    final standardTimes = {'Sabah', 'Öğle', 'Akşam'};
    
    for (int medIndex = 0; medIndex < _savedMedications.length; medIndex++) {
      final med = _savedMedications[medIndex];
      final doseUsageTimes = med['doseUsageTimes'] as List<String>;
      final doseTimes = med['doseTimes'] as List<TimeOfDay>;
      final doseAmounts = med['doseAmounts'] as List<String>;
      
      for (int i = 0; i < doseUsageTimes.length; i++) {
        final doseUsageTime = doseUsageTimes[i];
        
        // Check: if usageTime is "Diğer", match non-standard times; otherwise match exact
        final shouldInclude = usageTime == 'Diğer'
            ? !standardTimes.contains(doseUsageTime)
            : doseUsageTime == usageTime;
        
        if (shouldInclude) {
          final timeStr = '${doseTimes[i].hour.toString().padLeft(2, '0')}:${doseTimes[i].minute.toString().padLeft(2, '0')}';
          medications.add(
            MedicationCardData(
              name: med['name'] as String,
              dosage: doseAmounts[i],
              time: timeStr,
              icon: Icons.medication,
              iconColor: Colors.blue.shade300,
              dosageColor: Colors.blue,
              isTaken: (med['takenFlags'] != null && (med['takenFlags'] as List).length > i)
                  ? (med['takenFlags'] as List)[i] as bool
                  : false,
              parentIndex: medIndex,
              doseIndex: i,
            ),
          );
        }
      }
    }
    return medications;
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
            progress: _computeProgress(),
            takenLabel: _computeTakenLabel(),
            nextDoseLabel: _computeNextDoseLabel(),
          ),
          const SizedBox(height: 24),
          if (_getMedicationsForSection('Sabah').isNotEmpty) ...[
            MedicationSection(
              title: 'Sabah',
              medications: _getMedicationsForSection('Sabah'),
              onToggle: (data) {
                setState(() {
                  final current = _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] as bool;
                  _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] = !current;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
          if (_getMedicationsForSection('Öğle').isNotEmpty) ...[
            MedicationSection(
              title: 'Öğle',
              medications: _getMedicationsForSection('Öğle'),
              onToggle: (data) {
                setState(() {
                  final current = _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] as bool;
                  _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] = !current;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
          if (_getMedicationsForSection('Akşam').isNotEmpty) ...[
            MedicationSection(
              title: 'Akşam',
              medications: _getMedicationsForSection('Akşam'),
              onToggle: (data) {
                setState(() {
                  final current = _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] as bool;
                  _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] = !current;
                });
              },
            ),
            const SizedBox(height: 16),
          ],
          if (_getMedicationsForSection('Diğer').isNotEmpty) ...[
            MedicationSection(
              title: 'Diğer',
              medications: _getMedicationsForSection('Diğer'),
              onToggle: (data) {
                setState(() {
                  final current = _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] as bool;
                  _savedMedications[data.parentIndex]['takenFlags'][data.doseIndex] = !current;
                });
              },
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute<Map<String, dynamic>>(
              builder: (context) => const AddMedicationScreen(),
            ),
          );
          if (result != null) {
            setState(() {
              // initialize taken flags per dose for tracking
              final int totalDoses = (result['doseAmounts'] as List?)?.length ?? (result['doseUsageTimes'] as List?)?.length ?? 0;
              result['takenFlags'] = List<bool>.filled(totalDoses, false);
              _savedMedications.add(result);
            });
          }
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

  double _computeProgress() {
    int total = 0;
    int taken = 0;
    for (final med in _savedMedications) {
      final flags = med['takenFlags'] as List?;
      if (flags != null) {
        total += flags.length;
        for (final f in flags) {
          if (f == true) taken++;
        }
      } else {
        final amounts = med['doseAmounts'] as List?;
        if (amounts != null) total += amounts.length;
      }
    }
    if (total == 0) return 0.0;
    return taken / total;
  }

  String _computeTakenLabel() {
    int total = 0;
    int taken = 0;
    for (final med in _savedMedications) {
      final flags = med['takenFlags'] as List?;
      if (flags != null) {
        total += flags.length;
        for (final f in flags) {
          if (f == true) taken++;
        }
      } else {
        final amounts = med['doseAmounts'] as List?;
        if (amounts != null) total += amounts.length;
      }
    }
    return '$taken/$total İlaç Alındı';
  }

  String _computeNextDoseLabel() {
    int total = 0;
    int taken = 0;
    TimeOfDay? nextUntakenTime;
    
    // Tüm ilaçlardan saatler ve taken durumunu kontrol et
    for (final med in _savedMedications) {
      final doseTimes = med['doseTimes'] as List<TimeOfDay>?;
      final flags = med['takenFlags'] as List?;
      
      if (doseTimes != null) {
        for (int i = 0; i < doseTimes.length; i++) {
          final isTaken = flags != null && i < flags.length ? flags[i] == true : false;
          total++;
          
          if (isTaken) {
            taken++;
          } else {
            // Alınmamış ilaç — en yakın saati bul
            final time = doseTimes[i];
            if (nextUntakenTime == null || 
                time.hour < nextUntakenTime.hour ||
                (time.hour == nextUntakenTime.hour && time.minute < nextUntakenTime.minute)) {
              nextUntakenTime = time;
            }
          }
        }
      }
    }
    
    // Case 1: Hiç ilaç alınmadı
    if (taken == 0) {
      return 'Hiç İlaç Alınmadı';
    }
    
    // Case 2: Tüm ilaçlar alındı
    if (taken == total) {
      return 'Tüm İlaçlar Alındı';
    }
    
    // Case 3: Sonraki alınmamış ilaç saati
    if (nextUntakenTime != null) {
      final timeStr = '${nextUntakenTime.hour.toString().padLeft(2, '0')}:${nextUntakenTime.minute.toString().padLeft(2, '0')}';
      return "Sonraki doz: $timeStr'de";
    }
    
    return 'Tüm İlaçlar Alındı';
  }
}
