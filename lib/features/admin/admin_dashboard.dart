import 'package:flutter/material.dart';
import '../../core/widgets/dashboard_scaffold.dart';
import '../../core/widgets/dashboard_section_title.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Admin',
      children: const [
        DashboardSectionTitle('Admin Dashboard (MVP)'),
        SizedBox(height: 12),
        Center(child: Text('Admin Dashboard (MVP)')),
      ],
    );
  }
}
