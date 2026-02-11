// lib/presentation/screens/active_timer_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../widgets/active_timer/timer_display.dart'; 
import '../widgets/active_timer/post_exercise_sugar_input.dart'; 
import '../widgets/active_timer/status_action_button.dart';

class ActiveTimerScreen extends StatefulWidget {
  final String title;
  final int targetMinutes;

  const ActiveTimerScreen({
    super.key, 
    required this.title, 
    this.targetMinutes = 30,
  });

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
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

  // --- POP-UP MANTIĞI ---

  void _handleFinish() async {
    bool sugarEmpty = _sugarController.text.isEmpty;
    bool timeNotFinished = (_seconds > 0 && !_isPreparing);

    // DURUM 1: HEM SÜRE DOLMADI HEM ŞEKER BOŞ
    if (sugarEmpty && timeNotFinished) {
      bool confirm = await _showCombinedWarning();
      if (confirm && mounted) Navigator.of(context).pop();
      return;
    }

    // DURUM 2: SADECE SÜRE DOLMADI
    if (timeNotFinished) {
      bool confirm = await _showExitConfirmation();
      if (confirm && mounted) Navigator.of(context).pop();
      return;
    }

    // DURUM 3: SADECE ŞEKER BOŞ
    if (sugarEmpty) {
      bool confirm = await _showSugarConfirmation();
      if (confirm && mounted) Navigator.of(context).pop();
      return;
    }

    // DURUM 4: HER ŞEY TAMAM
    Navigator.of(context).pop();
  }

  // Ortak Uyarı Penceresi (Süre + Şeker)
  Future<bool> _showCombinedWarning() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Dikkat!"),
          ],
        ),
        content: const Text(
          "Egzersiz süreniz henüz dolmadı ve şeker seviyenizi girmediniz. Bu şekilde bitirirseniz verileriniz kaydedilmeyecektir. Yine de devam etmek istiyor musunuz?"
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("GERİ DÖN")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("BİTİR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Süre Dolmadı"),
        content: const Text("Egzersiz süreniz bitmeden çıkmak istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("HAYIR")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("EVET, ÇIK")),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showSugarConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Şeker Verisi Eksik"),
        content: const Text("Şeker seviyenizi girmediniz. Devam etmek istiyor musunuz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("GERİ DÖN")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("DEVAM ET")),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = _isPreparing ? 1.0 : (_seconds / (widget.targetMinutes * 60));

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleFinish(); // Geri tuşu da artık aynı akıllı kontrolü yapıyor
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(widget.title, style: const TextStyle(color: Color(0xFF148377), fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.secondary),
            onPressed: _handleFinish,
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
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 100), 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: StatusActionButton(
                      label: _seconds == 0 ? "Tamamladım" : "Egzersizi Bitir",
                      onPressed: _handleFinish, 
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isPreparing ? "HAZIRLAN..." : "● OTURUM DEVAM EDİYOR", 
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildSafetyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.security, color: Color(0xFF148377), size: 14),
          SizedBox(width: 8),
          Text("Önce Güvenlik: Başınız dönerse durun.", style: TextStyle(color: Color(0xFF148377), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sugarController.dispose();
    super.dispose();
  }
}