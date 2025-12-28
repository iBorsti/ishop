import 'package:flutter/material.dart';

class FleetHomeScreen extends StatelessWidget {
  const FleetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flota - Inicio')),
      body: const Center(child: Text('Inicio flota')),
    );
  }
}
