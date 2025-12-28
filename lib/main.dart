import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/role_selector_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mercado Nica',
      theme: AppTheme.lightTheme,
      home: const RoleSelectorScreen(),
    );
  }
}
