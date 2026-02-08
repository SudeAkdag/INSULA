// İlaç Ekle sayfası. Widget'lar presentation/widgets/add_medication/ altındaki
// ayrı dosyalardan import edilir (form kartı, doz kartları, notlar, kaydet butonu).
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/add_medication/add_medication_form_card.dart';
import '../widgets/add_medication/add_medication_dose_card.dart';
import '../widgets/add_medication/add_medication_notes_card.dart';
import '../widgets/add_medication/add_medication_save_button.dart';
import '../widgets/add_medication/bottom_sheets/medication_type_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/usage_time_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/usage_status_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/frequency_bottom_sheet.dart';
import '../widgets/add_medication/bottom_sheets/dose_amount_bottom_sheet.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  String _medicationType = 'Tür Seçiniz';
  String _dosage = '10 mg';
  String _frequency = 'Günde 1 kez';

  late List<TimeOfDay> _doseTimes;
  late List<String> _doseAmounts;
  late List<String> _doseUsageTimes;
  late List<String> _doseConditions;

  @override
  void initState() {
    super.initState();
    _initializeDoses();
  }

  void _initializeDoses() {
    final doseCount = _extractDoseCount(_frequency);
    _doseTimes = List.generate(
      doseCount,
      (i) => TimeOfDay(hour: 8 + (i * 6), minute: 0),
    );
    _doseAmounts = List.filled(doseCount, '1 Tablet');
    _doseUsageTimes = List.filled(doseCount, 'Sabah');
    _doseConditions = List.filled(doseCount, 'Aç');
  }

  int _extractDoseCount(String frequency) {
    // Parse "Günde X kez" and extract the number X
    if (frequency.contains('1')) return 1;
    if (frequency.contains('2')) return 2;
    if (frequency.contains('3')) return 3;
    if (frequency.contains('4')) return 4;
    if (frequency == 'Gün aşırı') return 1;
    if (frequency.contains('Haftada')) return 1;
    return 2; // Default
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TimeOfDay initial, void Function(TimeOfDay) onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) onPicked(picked);
  }

  void _showOptions(BuildContext context, List<String> options, void Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((o) => ListTile(
                    title: Text(o, style: AppTextStyles.body),
                    onTap: () {
                      onSelect(o);
                      Navigator.pop(ctx);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    
    // Simple validation: require medication name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ilaç adını girin')),
      );
      return;
    }

    // Build medication data from the form and dose cards
    final medicationData = {
      'name': name,
      'medicationType': _medicationType,
      'dosage': _dosage,
      'frequency': _frequency,
      'doseTimes': _doseTimes,
      'doseAmounts': _doseAmounts,
      'doseUsageTimes': _doseUsageTimes,
      'doseConditions': _doseConditions,
      'notes': _notesController.text.trim(),
    };
    
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
        title: Text(
          "İlaç Ekle",
          style: AppTextStyles.h1.copyWith(color: AppColors.secondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddMedicationFormCard(
                nameController: _nameController,
                medicationType: _medicationType,
                dosage: _dosage,
                frequency: _frequency,
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
                onDosageTap: () => _showOptions(
                  context,
                  ['10 mg', '500 mg', '1000 mg'],
                  (v) => setState(() => _dosage = v),
                ),
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
                nameValidator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'İlaç adı girin' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Kullanım Zamanları',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentTeal,
                ),
              ),
              const SizedBox(height: 12),
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
                    if (index < _doseTimes.length - 1) const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AddMedicationNotesCard(controller: _notesController),
              const SizedBox(height: 32),
              AddMedicationSaveButton(onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
