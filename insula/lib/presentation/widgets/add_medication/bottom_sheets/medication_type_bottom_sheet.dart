import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'confirm_selection_button.dart';

/// İlaç türü seçimi için bottom sheet: başlık, açıklama, radyo listesi, onay butonu.
/// "İlaç Türü" alanına tıklandığında gösterilir.
class MedicationTypeBottomSheet extends StatefulWidget {
  final String? initialValue;
  final void Function(String) onConfirm;

  const MedicationTypeBottomSheet({
    super.key,
    this.initialValue,
    required this.onConfirm,
  });

  static const List<MedicationTypeOption> options = [
    MedicationTypeOption('Tablet', 'Hap formundaki katı ilaçlar', Icons.medication),
    MedicationTypeOption('Kapsül', 'Jel veya sert kaplı kapsüller', Icons.medication),
    MedicationTypeOption('Enjeksiyon', 'Şırınga ile uygulananlar', Icons.vaccines),
    MedicationTypeOption('İnsülin', 'İnsülin kalemi veya enjektörü', Icons.medical_services),
    MedicationTypeOption('Sprey', 'Burun veya ağız spreyleri', Icons.air),
    MedicationTypeOption('Diğer', 'Diğer formlardaki ilaçlar', Icons.more_horiz),
  ];

  @override
  State<MedicationTypeBottomSheet> createState() => _MedicationTypeBottomSheetState();
}

class MedicationTypeOption {
  final String title;
  final String description;
  final IconData icon;

  const MedicationTypeOption(this.title, this.description, this.icon);
}

class _MedicationTypeBottomSheetState extends State<MedicationTypeBottomSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    final validTitles = MedicationTypeBottomSheet.options.map((o) => o.title).toList();

    _selected = (initial != null && validTitles.contains(initial))
        ? initial
        : validTitles.first;
  }

  void _confirm() {
    widget.onConfirm(_selected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Force sheet to occupy 82% of the device screen height so
        // it reliably covers most of the screen even if caller
        // didn't set isScrollControlled.
        final maxH = MediaQuery.of(context).size.height * 0.82;

        return Container(
          height: maxH,
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              )
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 56,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İlaç Türü Seçin',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 20,
                          color: AppColors.accentTeal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lütfen ilacınızın formunu listeden belirleyin.',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: MedicationTypeBottomSheet.options.length,
                    itemBuilder: (context, index) {
                      final option = MedicationTypeBottomSheet.options[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _selected = option.title),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentTeal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      option.icon,
                                      color: AppColors.accentTeal,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.title,
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accentTeal,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option.description,
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 10,
                                            color: AppColors.textSecLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Radio<String>(
                                    value: option.title,
                                    groupValue: _selected,
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selected = v);
                                    },
                                    activeColor: AppColors.primary,
                                    fillColor: MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return AppColors.primary;
                                      }
                                      return Colors.grey.shade400;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withOpacity(0.95),
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: ConfirmSelectionButton(onPressed: _confirm),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
