import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_constants.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
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
        actions: [
          TextButton(
            onPressed: null, // UI-only
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
                  // Takvim Gün Şeridi + İlerleme Kartı
                  _buildProgressCard(),
                  
                  const SizedBox(height: 24),
                  
                  // İlaç Bölümleri
                  _buildMedicationSection(
                    title: 'Sabah',
                    medications: [
                      _MedicationData(
                        name: 'Insulin Aspart',
                        dosage: '10 Ünite',
                        time: '08:00',
                        icon: Icons.medication_liquid,
                        iconColor: Colors.lightBlue,
                        dosageColor: Colors.blue,
                        isTaken: true,
                      ),
                      _MedicationData(
                        name: 'Diamicron',
                        dosage: '60 mg',
                        time: '06:30',
                        icon: Icons.medication,
                        iconColor: Colors.red.shade300,
                        dosageColor: Colors.red,
                        isTaken: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMedicationSection(
                    title: 'Öğle',
                    medications: [
                      _MedicationData(
                        name: 'Metformin',
                        dosage: '1000 mg',
                        time: '13:00',
                        icon: Icons.medication,
                        iconColor: Colors.red.shade300,
                        dosageColor: Colors.red,
                        isTaken: true,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMedicationSection(
                    title: 'Akşam',
                    medications: [
                      _MedicationData(
                        name: 'Insulin Glargine',
                        dosage: '24 Ünite',
                        time: '20:00',
                        icon: Icons.medication_liquid,
                        iconColor: Colors.lightBlue,
                        dosageColor: Colors.blue,
                        isTaken: false,
                      ),
                    ],
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: null, // UI-only
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full), // Tam yuvarlak
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gün Şeridi
          CalendarDayStrip(
            selectedDate: _selectedDate ?? DateTime.now(),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // İlerleme Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Günlük İlerleme',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '75%',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.75,
              minHeight: 10,
              backgroundColor: AppColors.backgroundLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Alt Satır
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3/4 Doz Alındı',
                style: AppTextStyles.label,
              ),
              Text(
                'Sonraki doz: 20:00\'de',
                style: AppTextStyles.label,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationSection({
    required String title,
    required List<_MedicationData> medications,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h1.copyWith(
            fontSize: 18,
            color: AppColors.accentTeal,
          ),
        ),
        const SizedBox(height: 12),
        ...medications.map((med) => _MedicationCard(medication: med)),
      ],
    );
  }
}

// Takvim Gün Şeridi Widget'ı
class CalendarDayStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarDayStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    // Ayın tüm günlerini oluştur
    final days = List.generate(daysInMonth, (index) {
      return DateTime(now.year, now.month, index + 1);
    });

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day, selectedDate);
          final isToday = _isSameDay(day, now);
          final yesterday = now.subtract(const Duration(days: 1));
          final tomorrow = now.add(const Duration(days: 1));
          final isYesterday = _isSameDay(day, yesterday);
          final isTomorrow = _isSameDay(day, tomorrow);
          
          String dayLabel;
          if (isToday) {
            dayLabel = 'BUGÜN';
          } else if (isYesterday) {
            dayLabel = 'DÜN';
          } else if (isTomorrow) {
            dayLabel = 'YARIN';
          } else {
            // Haftanın günü kısaltması
            final weekdays = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];
            dayLabel = weekdays[day.weekday - 1];
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onDateSelected(day),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayLabel,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected 
                            ? AppColors.secondary 
                            : AppColors.textSecLight,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected 
                            ? AppColors.secondary 
                            : AppColors.textMainLight,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// İlaç Veri Modeli
class _MedicationData {
  final String name;
  final String dosage;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color dosageColor;
  final bool isTaken;

  _MedicationData({
    required this.name,
    required this.dosage,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.dosageColor,
    required this.isTaken,
  });
}

// İlaç Kartı Widget'ı
class _MedicationCard extends StatelessWidget {
  final _MedicationData medication;

  const _MedicationCard({required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol: İkon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: medication.iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              medication.icon,
              color: medication.iconColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Orta: İlaç Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      medication.dosage,
                      style: AppTextStyles.label.copyWith(
                        color: medication.dosageColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • +${medication.time}',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Sağ: Checkbox
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: medication.isTaken
                  ? AppColors.secondary
                  : Colors.transparent,
              border: Border.all(
                color: medication.isTaken
                    ? AppColors.secondary
                    : AppColors.textSecLight.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: medication.isTaken
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
