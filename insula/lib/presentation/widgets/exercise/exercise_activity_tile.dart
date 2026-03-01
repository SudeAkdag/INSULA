import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/exercise_service.dart';
import '../../screens/active_timer_screen.dart';
import '../active_timer/status_action_button.dart';

class ExerciseActivityTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String calories;
  final IconData icon;
  final bool isCompleted;
  final int duration;
  final String? exerciseId;
  final double? initialSugar;

  const ExerciseActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.calories,
    required this.icon,
    required this.isCompleted,
    required this.duration,
    this.exerciseId,
    this.initialSugar,
  });

  @override
  State<ExerciseActivityTile> createState() => _ExerciseActivityTileState();
}

class _ExerciseActivityTileState extends State<ExerciseActivityTile> {
  final ExerciseService _exerciseService = ExerciseService();
  
  // UI'dan anlık silme için kontrol değişkeni
  bool _isDeleted = false;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: AppColors.accentOrange),
            const SizedBox(width: 10),
            const Text("Egzersizi Sil"),
          ],
        ),
        content: const Text("Bu egzersiz kalıcı olarak silinecektir. Emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İPTAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              if (widget.exerciseId != null) {
                // 1. Önce diyaloğu kapat (Kullanıcı bekletilmesin)
                Navigator.pop(context);

                try {
                  // 2. Veritabanından (Doğru adresten) sil
                  await _exerciseService.deleteExercise(widget.exerciseId!);

                  // 3. Widget'ı anında UI'dan kaldır
                  if (mounted) {
                    setState(() {
                      _isDeleted = true;
                    });

                    // Başarı mesajı göster
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Egzersiz başarıyla silindi"),
                        backgroundColor: AppColors.accentOrange,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Hata durumunda kullanıcıyı uyar ve UI'ı geri getir
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Silme işlemi başarısız oldu!")),
                    );
                  }
                }
              }
            },
            child: const Text("SİL", 
              style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- DÜZENLEME SHEET'İ ---
  void _showEditSheet() {
    final TextEditingController sugarController = TextEditingController(
      text: widget.initialSugar?.toString() ?? "",
    );
    int tempDuration = widget.duration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            top: 20,
            left: 25,
            right: 25,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Egzersizi Düzenle",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Hedef Süre:", style: TextStyle(fontWeight: FontWeight.w600)),
                  Text("$tempDuration dk", 
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  tickMarkShape: SliderTickMarkShape.noTickMark, // Noktaları kaldırdık
                ),
                child: Slider(
                  value: tempDuration.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  activeColor: AppColors.secondary,
                  inactiveColor: AppColors.backgroundLight,
                  onChanged: (val) => setModalState(() => tempDuration = val.toInt()),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Başlangıç Şekeri:", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: sugarController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "Ölçüm girin (opsiyonel)",
                  suffixText: "mg/dL",
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (widget.exerciseId != null) {
                      await _exerciseService.updateExerciseFields(
                        id: widget.exerciseId!,
                        duration: tempDuration,
                        sugarBefore: double.tryParse(sugarController.text),
                      );
                    }
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text("DEĞİŞİKLİKLERİ KAYDET",
                    style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Eğer silindiyse boş bir alan döndür (UI'dan anlık kalkar)
    if (_isDeleted) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: !widget.isCompleted 
            ? Border(left: BorderSide(color: AppColors.primary, width: 5))
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.backgroundLight,
            child: Icon(widget.icon, color: AppColors.secondary, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: AppColors.textSecLight, fontSize: 13),
                ),
                if (!widget.isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMiniButton(
                        label: "Düzenle",
                        icon: Icons.edit_rounded,
                        color: AppColors.secondary,
                        onTap: _showEditSheet,
                      ),
                      const SizedBox(width: 8),
                      _buildMiniButton(
                        label: "Sil",
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.accentOrange,
                        onTap: _confirmDelete,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          widget.isCompleted
              ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 36)
              : SizedBox(
                  width: 65,
                  height: 32,
                  child: StatusActionButton(
                    label: "BAŞLA",
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveTimerScreen(
                          title: widget.title,
                          targetMinutes: widget.duration,
                          exerciseId: widget.exerciseId,
                          initialSugar: widget.initialSugar,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMiniButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}