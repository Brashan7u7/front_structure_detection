import 'package:flutter/material.dart';
import 'package:scanner_flow/config/theme/app_theme.dart';
import 'package:scanner_flow/presentation/screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Capturar Foto',
      theme: AppTheme(selectedColor: 7).theme(),
      home: const HomeScreen(),
    );
  }
}
