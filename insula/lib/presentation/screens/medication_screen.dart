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
import 'medication_detail_screen.dart';
import '../../data/services/medication_service.dart';
import 'dart:async';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _savedMedications = [];
  final MedicationService _medicationService = MedicationService();
  StreamSubscription? _medicationSubscription;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _listenToMedications();
  }

  void _listenToMedications() {
    _medicationSubscription = _medicationService.getMedications().listen((medications) {
      if (mounted) {
        setState(() {
          _savedMedications = medications;
        });
      }
    });
  }

  @override
  void dispose() {
    _medicationSubscription?.cancel();
    super.dispose();
  }

  void _navigateToMedicationDetail(MedicationCardData data) {
    final medication = _savedMedications[data.parentIndex];
    final medicationIndex = data.parentIndex;
    Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder: (context) => MedicationDetailScreen(medication: medication),
      ),
    ).then((result) async {
      if (!mounted) return;
      
      if (result == true) {
        // İlaç silindi
        final String? docId = medication['id'] as String?;
        if (docId != null) {
          await _medicationService.deleteMedication(docId);
        }
      } else if (result is Map<String, dynamic>) {
        // İlaç güncellendi
        final String? docId = medication['id'] as String?;
        if (docId != null) {
          await _medicationService.updateMedication(docId, result);
        }
      }
    });
  }

  List<MedicationCardData> _getMedicationsForSection(String usageTime) {
    final medications = <MedicationCardData>[];
    final standardTimes = {'Sabah', 'Öğle', 'Akşam'};
    
    for (int medIndex = 0; medIndex < _savedMedications.length; medIndex++) {
      final med = _savedMedications[medIndex];
      
      // Tarih filtrelemesi
      final DateTime? startDate = med['startDate'] != null ? med['startDate'] as DateTime : null;
      final DateTime? endDate = med['endDate'] != null ? med['endDate'] as DateTime : null;
      final selectedDate = _selectedDate ?? DateTime.now();

      // Sadece günü karşılaştır
      final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      
      if (startDate != null) {
        final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
        if (selectedDateOnly.isBefore(startDateOnly)) continue;
      }
      
      if (endDate != null) {
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
        if (selectedDateOnly.isAfter(endDateOnly)) continue;
      }

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
              onToggle: (data) async {
                final med = _savedMedications[data.parentIndex];
                final docId = med['id'] as String;
                final currentFlags = List<bool>.from(med['takenFlags'] as List);
                currentFlags[data.doseIndex] = !currentFlags[data.doseIndex];
                
                await _medicationService.updateMedication(docId, {'takenFlags': currentFlags});
              },
              onMedicationTap: _navigateToMedicationDetail,
            ),
            const SizedBox(height: 16),
          ],
          if (_getMedicationsForSection('Öğle').isNotEmpty) ...[
            MedicationSection(
              title: 'Öğle',
              medications: _getMedicationsForSection('Öğle'),
              onToggle: (data) async {
                final med = _savedMedications[data.parentIndex];
                final docId = med['id'] as String;
                final currentFlags = List<bool>.from(med['takenFlags'] as List);
                currentFlags[data.doseIndex] = !currentFlags[data.doseIndex];
                
                await _medicationService.updateMedication(docId, {'takenFlags': currentFlags});
              },
              onMedicationTap: _navigateToMedicationDetail,
            ),
            const SizedBox(height: 16),
          ],
          if (_getMedicationsForSection('Akşam').isNotEmpty) ...[
            MedicationSection(
              title: 'Akşam',
              medications: _getMedicationsForSection('Akşam'),
              onToggle: (data) async {
                final med = _savedMedications[data.parentIndex];
                final docId = med['id'] as String;
                final currentFlags = List<bool>.from(med['takenFlags'] as List);
                currentFlags[data.doseIndex] = !currentFlags[data.doseIndex];
                
                await _medicationService.updateMedication(docId, {'takenFlags': currentFlags});
              },
              onMedicationTap: _navigateToMedicationDetail,
            ),
            const SizedBox(height: 16),
          ],
          if (_getMedicationsForSection('Diğer').isNotEmpty) ...[
            MedicationSection(
              title: 'Diğer',
              medications: _getMedicationsForSection('Diğer'),
              onToggle: (data) async {
                final med = _savedMedications[data.parentIndex];
                final docId = med['id'] as String;
                final currentFlags = List<bool>.from(med['takenFlags'] as List);
                currentFlags[data.doseIndex] = !currentFlags[data.doseIndex];
                
                await _medicationService.updateMedication(docId, {'takenFlags': currentFlags});
              },
              onMedicationTap: _navigateToMedicationDetail,
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
            await _medicationService.saveMedication(result);
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
