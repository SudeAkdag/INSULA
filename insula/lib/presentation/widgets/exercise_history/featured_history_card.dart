import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FeaturedHistoryCard extends StatelessWidget {
  const FeaturedHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1502904550040-7534597429ae?q=80&w=1000'), 
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Karartma katmanı (Yazıların okunması için AppColors üzerinden gradyan)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, 
                  // AppColors.secondary genellikle koyu ton olduğu için gölge için idealdir
                  AppColors.secondary.withValues(alpha: 0.7), 
                ],
              ),
            ),
          ),
          // Yazı İçeriği
          const Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sahil Koşusu", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 18
                  )
                ),
                Text(
                  "Pazartesi, 19:00", 
                  style: TextStyle(
                    color: Colors.white70, 
                    fontSize: 12
                  )
                ),
              ],
            ),
          ),
          // Değişim Göstergesi (AppColors.primary ile uyumlu hale getirildi)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // Arka planı hafif beyaz/şeffaf tutarak kontrast sağladık
                color: Colors.white.withValues(alpha: 0.2), 
                borderRadius: BorderRadius.circular(12)
              ),
              child: const Icon(
                Icons.show_chart, 
                // Grafik ikonu ana turkuaz renginizden geliyor
                color: AppColors.primary, 
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}