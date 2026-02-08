// İlaç Ekle sayfası. Widget'lar presentation/widgets/add_medication/ altındaki
// ayrı dosyalardan import edilir (form kartı, doz kartları, notlar, kaydet butonu).
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/add_medication/add_medication_form_card.dart';
import '../widgets/add_medication/add_medication_dose_card.dart';
import '../widgets/add_medication/add_medication_notes_card.dart';
import '../widgets/add_medication/add_medication_save_button.dart';

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
  String _frequency = 'Günde 2 kez';

  TimeOfDay _dose1Time = const TimeOfDay(hour: 8, minute: 0);
  String _dose1Amount = '1 Tablet';
  String _dose1UsageTime = 'Sabah';
  String _dose1Condition = 'Aç';

  TimeOfDay _dose2Time = const TimeOfDay(hour: 20, minute: 0);
  String _dose2Amount = '1 Tablet';
  String _dose2UsageTime = 'Akşam';
  String _dose2Condition = 'Tok';

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
                    title: Text(o),
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
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: İlaç kaydetme mantığı
      Navigator.pop(context);
    }
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
                onTypeTap: () => _showOptions(
                  context,
                  ['Tablet', 'Şurup', 'İğne', 'Kapsül'],
                  (v) => setState(() => _medicationType = v),
                ),
                onDosageTap: () => _showOptions(
                  context,
                  ['10 mg', '500 mg', '1000 mg'],
                  (v) => setState(() => _dosage = v),
                ),
                onFrequencyTap: () => _showOptions(
                  context,
                  ['Günde 1 kez', 'Günde 2 kez', 'Günde 3 kez', 'Haftada 1 kez'],
                  (v) => setState(() => _frequency = v),
                ),
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
              AddMedicationDoseCard(
                title: '1. DOZ',
                time: _dose1Time,
                onTimeTap: () => _pickTime(_dose1Time, (t) => setState(() => _dose1Time = t)),
                amount: _dose1Amount,
                usageTime: _dose1UsageTime,
                condition: _dose1Condition,
                onAmountTap: () => _showOptions(
                  context,
                  ['1 Tablet', '2 Tablet', '1 Ölçek'],
                  (v) => setState(() => _dose1Amount = v),
                ),
                onUsageTimeTap: () => _showOptions(
                  context,
                  ['Sabah', 'Öğle', 'Akşam', 'Gece'],
                  (v) => setState(() => _dose1UsageTime = v),
                ),
                onConditionTap: () => _showOptions(
                  context,
                  ['Aç', 'Tok'],
                  (v) => setState(() => _dose1Condition = v),
                ),
              ),
              const SizedBox(height: 12),
              AddMedicationDoseCard(
                title: '2. DOZ',
                time: _dose2Time,
                onTimeTap: () => _pickTime(_dose2Time, (t) => setState(() => _dose2Time = t)),
                amount: _dose2Amount,
                usageTime: _dose2UsageTime,
                condition: _dose2Condition,
                onAmountTap: () => _showOptions(
                  context,
                  ['1 Tablet', '2 Tablet', '1 Ölçek'],
                  (v) => setState(() => _dose2Amount = v),
                ),
                onUsageTimeTap: () => _showOptions(
                  context,
                  ['Sabah', 'Öğle', 'Akşam', 'Gece'],
                  (v) => setState(() => _dose2UsageTime = v),
                ),
                onConditionTap: () => _showOptions(
                  context,
                  ['Aç', 'Tok'],
                  (v) => setState(() => _dose2Condition = v),
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
