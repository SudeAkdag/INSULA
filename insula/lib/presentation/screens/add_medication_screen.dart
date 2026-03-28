// İlaç Ekle sayfası. Widget'lar presentation/widgets/add_medication/ altındaki
// ayrı dosyalardan import edilir (form kartı, doz kartları, notlar, kaydet butonu).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/medication_model.dart';
import '../widgets/add_medication/add_medication_form_card.dart';
import '../widgets/add_medication/add_medication_dose_card.dart';
import '../widgets/add_medication/add_medication_notes_card.dart';
import '../widgets/add_medication/add_medication_save_button.dart';
import '../widgets/add_medication/bottom_sheets/medication_type_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/usage_time_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/usage_status_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/frequency_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/dose_amount_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/dosage_selection_bottom_sheet.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _medicationType = 'Tür Seçiniz';
  String _dosage = '10 mg';
  String _frequency = 'Günde 1 kez';
  DateTime? _startDate;
  DateTime? _endDate;

  late List<TimeOfDay> _doseTimes;
  late List<String> _doseAmounts;
  late List<String> _doseUsageTimes;
  late List<String> _doseConditions;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _loadMedicationData();
    } else {
      _initializeDoses();
      _startDate = DateTime.now();
    }
  }

  void _loadMedicationData() {
    final med = widget.medication!;
    _nameController.text = med['name'] as String? ?? '';
    _medicationType = med['medicationType'] as String? ?? 'Tür Seçiniz';
    _dosage = med['dosage'] as String? ?? '10 mg';
    _frequency = med['frequency'] as String? ?? 'Günde 1 kez';
    _notesController.text = med['notes'] as String? ?? '';
    
    _startDate = med['startDate'] != null ? (med['startDate'] as DateTime) : null;
    _endDate = med['endDate'] != null ? (med['endDate'] as DateTime) : null;
    
    final doseTimes = med['doseTimes'] as List<TimeOfDay>?;
    final doseAmounts = med['doseAmounts'] as List<String>?;
    final doseUsageTimes = med['doseUsageTimes'] as List<String>?;
    final doseConditions = med['doseConditions'] as List<String>?;
    
    if (doseTimes != null && doseTimes.isNotEmpty) {
      _doseTimes = List<TimeOfDay>.from(doseTimes);
      _doseAmounts = List<String>.from(doseAmounts ?? []);
      _doseUsageTimes = List<String>.from(doseUsageTimes ?? []);
      _doseConditions = List<String>.from(doseConditions ?? []);
      
      while (_doseAmounts.length < _doseTimes.length) {
        _doseAmounts.add('1 Tablet');
      }
      while (_doseUsageTimes.length < _doseTimes.length) {
        _doseUsageTimes.add('Sabah');
      }
      while (_doseConditions.length < _doseTimes.length) {
        _doseConditions.add('Aç Karnına');
      }
      
      for (int i = 0; i < _doseConditions.length; i++) {
        if (_doseConditions[i].isEmpty || _doseConditions[i] == 'Aç') {
          _doseConditions[i] = 'Aç Karnına';
        }
      }
    } else {
      _initializeDoses();
    }
  }

  void _initializeDoses() {
    final doseCount = _extractDoseCount(_frequency);
    _doseTimes = List.generate(
      doseCount,
      (i) => TimeOfDay(hour: 8 + (i * 6), minute: 0),
    );
    _doseAmounts = List.filled(doseCount, '1 Tablet');
    _doseUsageTimes = List.filled(doseCount, 'Sabah');
    _doseConditions = List.filled(doseCount, 'Aç Karnına');
  }

  int _extractDoseCount(String frequency) {
    if (frequency.contains('1')) return 1;
    if (frequency.contains('2')) return 2;
    if (frequency.contains('3')) return 3;
    if (frequency.contains('4')) return 4;
    if (frequency == 'Gün aşırı') return 1;
    if (frequency.contains('Haftada')) return 1;
    return 2; 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _pickTime(TimeOfDay initial, void Function(TimeOfDay) onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickDate(DateTime? initial, void Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ilaç adını girin')),
      );
      return;
    }

    final medicationData = <String, dynamic>{
      'name': name,
      'medicationType': _medicationType,
      'dosage': _dosage,
      'frequency': _frequency,
      'doseTimes': _doseTimes,
      'doseAmounts': _doseAmounts,
      'doseUsageTimes': _doseUsageTimes,
      'doseConditions': _doseConditions,
      'startDate': _startDate,
      'endDate': _endDate,
      'notes': _notesController.text.trim(),
    };
    
    if (widget.medication != null) {
      if (widget.medication!['takenHistory'] != null) {
        medicationData['takenHistory'] = widget.medication!['takenHistory'];
      }
      
      if (widget.medication!['takenFlags'] != null) {
        final oldFlags = widget.medication!['takenFlags'] as List<bool>;
        final newDoseCount = _doseTimes.length;
        if (oldFlags.length == newDoseCount) {
          medicationData['takenFlags'] = List<bool>.from(oldFlags);
        } else {
          medicationData['takenFlags'] = List<bool>.filled(newDoseCount, false);
        }
      }
    } else {
      medicationData['takenHistory'] = <String, dynamic>{};
      medicationData['takenFlags'] = List<bool>.filled(_doseTimes.length, false);
    }
    
    Navigator.pop(context, medicationData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medication, color: AppColors.secondary, size: 24),
            const SizedBox(width: 8),
            Text(
              widget.medication != null ? "İlaç Düzenle" : "İlaç Ekle",
              style: AppTextStyles.h1.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddMedicationFormCard(
                nameController: _nameController,
                medicationType: _medicationType,
                dosage: _dosage,
                frequency: _frequency,
                startDate: _startDate,
                endDate: _endDate,
                onMedicationSelected: (med) {
                  setState(() {
                    _nameController.text = med.name;
                    _dosage = med.dosage;
                    if (med.form != null) {
                      _medicationType = _capitalize(med.form!);
                      if (widget.medication == null) {
                        for (int i = 0; i < _doseAmounts.length; i++) {
                          _doseAmounts[i] = "1 $_medicationType";
                        }
                      }
                    }
                  });
                },
                onTypeTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Container(
                      height: MediaQuery.of(ctx).size.height * 0.82,
                      child: MedicationTypeBottomSheet(
                        initialValue: _medicationType == 'Tür Seçiniz' ? null : _medicationType,
                        onConfirm: (v) => setState(() => _medicationType = v),
                      ),
                    ),
                  );
                },
                onDosageTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Container(
                      height: MediaQuery.of(ctx).size.height * 0.82,
                      child: DosageSelectionBottomSheet(
                        initialValue: _dosage == 'Dozaj' ? null : _dosage,
                        onConfirm: (v) => setState(() => _dosage = v),
                      ),
                    ),
                  );
                },
                onFrequencyTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Container(
                      height: MediaQuery.of(ctx).size.height * 0.82,
                      child: FrequencyBottomSheet(
                        initialValue: _frequency,
                        onConfirm: (v) {
                          setState(() {
                            _frequency = v;
                            _initializeDoses();
                          });
                        },
                      ),
                    ),
                  );
                },
                onStartDateTap: () => _pickDate(_startDate, (d) => setState(() => _startDate = d)),
                onEndDateTap: () => _pickDate(_endDate, (d) => setState(() => _endDate = d)),
                nameValidator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'İlaç adı girin' : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Kullanım Zamanları',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentTeal,
                ),
              ),
              const SizedBox(height: 2),
              ...List.generate(
                _doseTimes.length,
                (index) => Column(
                  children: [
                    AddMedicationDoseCard(
                      title: '${index + 1}. DOZ',
                      time: _doseTimes[index],
                      onTimeTap: () => _pickTime(_doseTimes[index], (t) {
                        setState(() => _doseTimes[index] = t);
                      }),
                      amount: _doseAmounts[index],
                      usageTime: _doseUsageTimes[index],
                      condition: _doseConditions[index],
                      onAmountTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Container(
                            height: MediaQuery.of(ctx).size.height * 0.82,
                            child: DoseAmountBottomSheet(
                              medicationType: _medicationType == 'Tür Seçiniz' ? 'Tablet' : _medicationType,
                              initialValue: _doseAmounts[index],
                              onConfirm: (v) => setState(() => _doseAmounts[index] = v),
                            ),
                          ),
                        );
                      },
                      onUsageTimeTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Container(
                            height: MediaQuery.of(ctx).size.height * 0.82,
                            child: UsageTimeBottomSheet(
                              initialValue: _doseUsageTimes[index],
                              onConfirm: (v) =>
                                  setState(() => _doseUsageTimes[index] = v),
                            ),
                          ),
                        );
                      },
                      onConditionTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Container(
                            height: MediaQuery.of(ctx).size.height * 0.82,
                            child: UsageStatusBottomSheet(
                              initialValue: _doseConditions[index],
                              onConfirm: (v) =>
                                  setState(() => _doseConditions[index] = v),
                            ),
                          ),
                        );
                      },
                    ),
                    if (index < _doseTimes.length - 1) const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AddMedicationNotesCard(controller: _notesController),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AddMedicationSaveButton(onPressed: _save),
        ),
      ),
    );
  }
}
