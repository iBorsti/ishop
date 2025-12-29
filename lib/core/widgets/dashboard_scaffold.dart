import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
