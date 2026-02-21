import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:insula/presentation/screens/main_screen.dart';
import 'core/theme/app_theme.dart'; // Temayı içe aktar
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insula/logic/viewmodels/auth_viewmodel.dart';
import 'package:insula/presentation/screens/auth/welcome_screen.dart';
import 'package:insula/presentation/screens/auth/profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthViewModel().user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const WelcomeScreen();
          }

          // User is logged in, check profile completion
          return FutureBuilder<bool>(
            future: AuthViewModel().isProfileComplete(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (profileSnapshot.hasData && profileSnapshot.data == true) {
                return const MainScreen();
              }

              return const ProfileSetupScreen();
            },
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
