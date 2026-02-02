// presentation/widgets/custom_side_drawer.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomSideDrawer extends StatelessWidget {
  const CustomSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // AppColors dosmandaki backgroundLight değişkenini kullandık
      backgroundColor: AppColors.backgroundLight, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Header - Arka planı temanın ikincil rengi (Lacivert) yaptık
          _buildDrawerHeader(),
          
          const SizedBox(height: 10),

          // Menü Elemanları
          _buildDrawerItem(Icons.person_outline, "Profil", () {}),
          _buildDrawerItem(Icons.bar_chart_outlined, "Raporlar", () {}),
          _buildDrawerItem(Icons.settings_outlined, "Ayarlar", () {}),
          _buildDrawerItem(Icons.smart_toy_outlined, "Chatbot", () {}),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(thickness: 1),
          ),

          // Çıkış Yap - Temadaki Turuncu/Kırmızı (Tertiary) rengini kullanabiliriz
          _buildDrawerItem(
            Icons.logout_rounded, 
            "Çıkış Yap", 
            () {}, 
            color: AppColors.tertiary 
          ),

          const Spacer(), 
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.secondary, // Lacivert tema rengi
        borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primary, // Sarı ana renk
            child: const Icon(Icons.person, color: AppColors.secondary, size: 40),
          ),
          const SizedBox(height: 15),
          const Text(
            "Ayşe Yılmaz",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            "ayse.yilmaz@ornek.com",
            style: TextStyle(
              color: Colors.white.withAlpha(100),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.secondary),
      title: Text(
        title,
        style: TextStyle(
          // Temadaki ana metin rengini kullandık
          color: color ?? AppColors.textMainLight, 
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      visualDensity: const VisualDensity(vertical: -1), // Listeyi biraz daha sıkı yapar
    );
  }
}