import 'package:flutter/material.dart';

import '../config/app_env.dart';

class DashboardScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  const DashboardScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    Widget? envBanner;
    if (AppConfig.isDemo) {
      envBanner = _EnvBanner(label: 'MODO DEMO', color: Colors.blueAccent);
    } else if (AppConfig.isPilot) {
      envBanner = _EnvBanner(label: 'PILOTO', color: Colors.orangeAccent);
    }

    final content = <Widget>[
      if (envBanner != null) envBanner,
      ...children,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        ),
      ),
    );
  }
}

class _EnvBanner extends StatelessWidget {
  final String label;
  final MaterialAccentColor color;

  const _EnvBanner({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.info_outline, color: color.shade700, size: 18),
        ],
      ),
    );
  }
}
