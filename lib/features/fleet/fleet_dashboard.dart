import 'package:flutter/material.dart';

class FleetDashboard extends StatelessWidget {
  const FleetDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Flota')),
      body: const Center(child: Text('Panel flota')),
    );
  }
}
