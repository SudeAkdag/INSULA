// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insula/presentation/screens/emergency_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../screens/profile_screen.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _displayName = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted)
          setState(() {
            _displayName = 'Kullanıcı';
            _loaded = true;
          });
        return;
      }
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = (doc.data()?['fullName'] as String?)?.trim() ?? '';
      if (mounted) {
        setState(() {
          _displayName = name.isNotEmpty ? name : 'Kullanıcı';
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _displayName = 'Kullanıcı';
          _loaded = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 24.0, top: 12.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  color: AppColors.primary.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: ClipOval(
                    child: Image.network(
                      "https://lh3.googleusercontent.com/...", // URL buraya gelecek
                      width: 40, // Boyutlandırma eklemek stabilite sağlar
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 28,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hoş geldin,",
                    style: AppTextStyles.label
                        .copyWith(fontSize: 10, color: Colors.black),
                  ),
                  _loaded
                      ? Text(
                          _displayName,
                          style: AppTextStyles.h1
                              .copyWith(fontSize: 16, height: 1.0),
                        )
                      : Container(
                          width: 100,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmergencyScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.warning_rounded),
                color: AppColors.tertiary,
                iconSize: 30,
              ),
              Text(
                "Acil Durum",
                style: AppTextStyles.label
                    .copyWith(fontSize: 10, color: AppColors.tertiary),
              ),
            ],
          )
        ],
      ),
    );
  }
}
