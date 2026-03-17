import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Kendi proje klasör yapına göre bu importları kontrol et
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'logic/viewmodels/auth_viewmodel.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/auth/profile_setup_screen.dart';

void main() async {
  // 1. Flutter alt yapısını hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Chatbot API anahtarları için .env dosyasını yükle
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env dosyası yoksa veya hatalıysa terminalde bizi uyarsın
    debugPrint("UYARI: .env dosyası yüklenemedi. Chatbot çalışmayabilir: $e");
  }

  // 3. Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const InsulaApp());
}

class InsulaApp extends StatelessWidget {
  const InsulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insula',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Türkçe tarih/saat desteği ve yerelleştirme
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('tr', 'TR'),
      
      // Giriş kontrol mekanizması
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthViewModel üzerinden kullanıcı durumunu dinliyoruz
    return StreamBuilder<User?>(
      stream: AuthViewModel().user,
      builder: (context, snapshot) {
        // Bağlantı aktifleşene kadar yükleniyor göster
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          // Kullanıcı giriş yapmamışsa Hoş Geldin ekranına
          if (user == null) {
            return const WelcomeScreen();
          }

          // Giriş yapmışsa: Profil bilgilerini doldurmuş mu kontrol et
          return FutureBuilder<bool>(
            future: AuthViewModel().isProfileComplete(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Profil tamamsa Ana Ekran, değilse Profil Kurulumu
              if (profileSnapshot.hasData && profileSnapshot.data == true) {
                return const MainScreen();
              }

              return const ProfileSetupScreen();
            },
          );
        }

        // İlk açılışta yükleme çemberi
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}