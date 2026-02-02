import 'package:flutter/material.dart';

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
          image: NetworkImage('https://images.unsplash.com/photo-1502904550040-7534597429ae?q=80&w=1000'), // Örnek manzara
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Karartma katmanı (Yazıların okunması için)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(180)],
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
                Text("Sahil Koşusu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Pazartesi, 19:00", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          // Değişim Göstergesi
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.show_chart, color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }
}