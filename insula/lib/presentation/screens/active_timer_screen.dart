// lib/presentation/screens/active_timer_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../widgets/active_timer/timer_display.dart'; 
import '../widgets/active_timer/post_exercise_sugar_input.dart'; 
import '../widgets/active_timer/status_action_button.dart';

class ActiveTimerScreen extends StatefulWidget {
  final String title;
  const ActiveTimerScreen({super.key, required this.title});

  @override
  State<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends State<ActiveTimerScreen> {
  int _seconds = 0;
  Timer? _timer;
  final TextEditingController _sugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sugarController.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.title, style: const TextStyle(color: Color(0xFF148377), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
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
                    formattedTime: _formatTime(_seconds),
                    seconds: _seconds,
                    progress: (_seconds % 60) / 60,
                  ),
                  const SizedBox(height: 60),
                  PostExerciseSugarInput(controller: _sugarController),
                ],
              ),
            ),
          ),
          // BUTONU YUKARI TAŞIYAN ALAN
          Padding(
            // Alttaki 40 değerini 100 yaparak butonu yukarı kaldırdık
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 100), 
            child: Column(
              mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar yer kaplasın
              children: [
                // Senin StatusActionButton sınıfını burada kullanıyoruz
                SizedBox(
                  height: 60, // Buton yüksekliğini sabitlemek iyi olur
                  width: double.infinity,
                  child: StatusActionButton(
                    label: "Tamamladım",
                    onPressed: () {
                      if (_sugarController.text.isNotEmpty) {
                        // Veritabanı kayıt mantığı buraya gelecek
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lütfen şeker seviyenizi girin")),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "● OTURUM DEVAM EDİYOR", 
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.security, color: Color(0xFF148377), size: 14),
          SizedBox(width: 8),
          Text("Önce Güvenlik: Başınız dönerse durun.", style: TextStyle(color: Color(0xFF148377), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}