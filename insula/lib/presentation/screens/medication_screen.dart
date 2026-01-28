import 'package:flutter/material.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("İlaç Takip Sayfası", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}