// lib/presentation/screens/active_timer_screen.dart
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
  Timer? _timer;
  final TextEditingController _sugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _seconds = widget.targetMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_isPreparing) {
          if (_prepSeconds > 0) _prepSeconds--;
          else _isPreparing = false;
        } else {
          if (_seconds > 0) _seconds--;
          else _timer?.cancel();
        }
      });
    });
  }

  Future<void> _saveAndExit() async {
    final double? postSugar = double.tryParse(_sugarController.text);
    
    ExerciseModel model = ExerciseModel(
     id: widget.exerciseId ?? '',
      activityName: widget.title,
      durationMinutes: widget.targetMinutes,
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

  void _handleFinish() async {
    bool sugarEmpty = _sugarController.text.isEmpty;
    bool timeNotFinished = (_seconds > 0 && !_isPreparing);

    if (!sugarEmpty && !timeNotFinished) {
      await _saveAndExit();
      return;
    }

    String content = "";
    if (sugarEmpty && timeNotFinished) {
      content = "Egzersiz süreniz henüz dolmadı ve şeker seviyenizi girmediniz. Bu şekilde bitirmek istiyor musunuz?";
    } else if (timeNotFinished) {
      content = "Egzersiz süreniz henüz dolmadı. Bitirmek istediğinize emin misiniz?";
    } else if (sugarEmpty) {
      content = "Şeker seviyenizi girmediniz. İstatistiklerinizin doğru hesaplanması için girmeniz önerilir. Devam edilsin mi?";
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text("Dikkat!", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
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
        _handleFinish(); 
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
            onPressed: _handleFinish
          ),
        ),
        body: Column(
          children: [
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
                    const SizedBox(height: 60),
                    PostExerciseSugarInput(controller: _sugarController),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 80),
              child: StatusActionButton(
                label: _seconds == 0 ? "Tamamladım" : "Egzersizi Bitir",
                onPressed: _handleFinish,
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
  void dispose() { _timer?.cancel(); _sugarController.dispose(); super.dispose(); }
}