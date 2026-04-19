import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise_model.dart';
import '../../data/services/exercise_service.dart';
import '../widgets/active_timer/timer_display.dart'; 
import '../widgets/active_timer/post_exercise_sugar_input.dart'; 
import '../widgets/active_timer/status_action_button.dart';

class ActiveTimerScreen extends StatefulWidget {
  final String title;
  final int targetMinutes;
  final double? initialSugar;
  final String? exerciseId; 

  const ActiveTimerScreen({
    super.key, 
    required this.title, 
    required this.targetMinutes, 
    this.initialSugar,
    this.exerciseId,
  });

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  late int _seconds;
  int _prepSeconds = 3;
  bool _isPreparing = true;
  bool _isPaused = false; 
  Timer? _timer;
  final TextEditingController _sugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seconds = widget.targetMinutes * 60;
    _startTimer();
  }

  // Timer'ı başlatan veya duraklatıldıktan sonra devam ettiren fonksiyon
  void _startTimer() {
    _timer?.cancel(); // Mevcut bir timer varsa önce onu temizle
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_isPreparing) {
          if (_prepSeconds > 0) {
            _prepSeconds--;
          } else {
            _isPreparing = false;
          }
        } else {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _timer?.cancel();
          }
        }
      });
    });
  }

  // Durdurma ve Başlatma mantığı
  void _togglePause() {
    setState(() {
      if (_isPaused) {
        _isPaused = false;
        _startTimer(); // Tekrar başlat
      } else {
        _isPaused = true;
        _timer?.cancel(); // Timer'ı tamamen durdur
      }
    });
  }

  Future<void> _saveAndExit() async {
    final double? postSugar = double.tryParse(_sugarController.text);
    
    // Yapılan süre hesabı (Saniye bazında farkı dakikaya yuvarla)
    int actualSeconds = (widget.targetMinutes * 60) - _seconds;
    int actualMinutes = (actualSeconds / 60).ceil(); 

    ExerciseModel model = ExerciseModel(
      id: widget.exerciseId ?? '',
      activityName: widget.title,
      durationMinutes: actualMinutes, 
      date: DateTime.now(),
      glucoseBefore: widget.initialSugar,
      glucoseAfter: postSugar,
      isCompleted: true,
    );

    if (widget.exerciseId != null) {
      await _exerciseService.updateExercise(model);
    } else {
      await _exerciseService.saveExercise(model);
    }

    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleCancelAndExit() async {
    String content = _isPaused 
        ? "Egzersiz mola durumunda. Eğer şimdi çıkarsanız ilerlemeniz kaydedilmeyecek ve süre başa dönecektir."
        : "Egzersiziniz tamamlanmamış sayılacak ve süreniz tekrar başlayacaktır. Çıkmak istediğinize emin misiniz?";

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Dikkat!", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(content, style: const TextStyle(color: AppColors.textSecLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("GERİ DÖN", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("ÇIK", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.of(context).pop(); 
    }
  }

  void _handleFinish() async {
    bool sugarEmpty = _sugarController.text.isEmpty;
    bool timeNotFinished = (_seconds > 0 && !_isPreparing);

    if (!sugarEmpty && !timeNotFinished) {
      await _saveAndExit();
      return;
    }

    String content = "";
    if (sugarEmpty && timeNotFinished) {
      content = "Egzersiz süreniz henüz dolmadı ve şeker seviyenizi girmediniz. Yapılan kısım kaydedilecektir. Bitirmek istiyor musunuz?";
    } else if (timeNotFinished) {
      content = "Egzersiz süreniz henüz dolmadı. Yapılan süreyi kaydetmek ve bitirmek istediğinize emin misiniz?";
    } else if (sugarEmpty) {
      content = "Şeker seviyenizi girmediniz. İstatistiklerinizin doğru hesaplanması için girmeniz önerilir. Devam edilsin mi?";
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text("Dikkat!", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(content, style: const TextStyle(color: AppColors.textSecLight)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("GERİ DÖN", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("YİNE DE BİTİR", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _saveAndExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = _isPreparing ? 1.0 : (_seconds / (widget.targetMinutes * 60));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, r) { 
        if(didPop) return;
        _handleCancelAndExit(); 
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.secondary), 
            onPressed: _handleCancelAndExit 
          ),
        ),
        body: Column(
          children: [
            // Üst kısım: Sayaç ve giriş alanları
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildSafetyBadge(),
                    const SizedBox(height: 40),
                    TimerDisplay(
                      formattedTime: _isPreparing 
                          ? (_prepSeconds > 0 ? "$_prepSeconds" : "BAŞLA!") 
                          : _formatTime(_seconds),
                      seconds: _isPreparing ? _prepSeconds : _seconds,
                      progress: progressValue,
                    ),
                    const SizedBox(height: 30),
                    // DURDURMA / DEVAM ET BUTONU
                    if (!_isPreparing && _seconds > 0)
                      GestureDetector(
                        onTap: _togglePause,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                            color: AppColors.primary,
                            size: 48,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30), // Metin kutusunun üstündeki boşluk
                    PostExerciseSugarInput(controller: _sugarController),
                    const SizedBox(height: 20), // Klavye açıldığında rahatlık sağlar
                  ],
                ),
              ),
            ),
            // Alt kısım: Egzersizi Bitir butonu
            // SafeArea kullanarak telefonun alt barına çarpmasını engelliyoruz
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 30), // Alttan 30 birim boşluk
                child: StatusActionButton(
                  label: _seconds == 0 ? "Tamamladım" : "Egzersizi Bitir",
                  onPressed: _handleFinish, 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSafetyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, color: AppColors.secondary.withOpacity(0.7), size: 14),
          const SizedBox(width: 8),
          Text(
            "Önce Güvenlik: Başınız dönerse durun.",
            style: TextStyle(color: AppColors.secondary.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTime(int s) => '${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}';

  @override
  void dispose() { 
    _timer?.cancel(); 
    _sugarController.dispose(); 
    super.dispose(); 
  }
}