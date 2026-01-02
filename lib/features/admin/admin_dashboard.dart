import 'package:flutter/material.dart';
import '../../core/widgets/dashboard_scaffold.dart';
import '../../core/widgets/dashboard_section_title.dart';
import 'services/admin_service.dart';
import 'widgets/admin_stat_section.dart';
import 'widgets/admin_role_summary_section.dart';
import 'widgets/admin_activity_list.dart';
import '../../core/metrics/metrics_service.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  Future<Map<String, dynamic>> _loadAll() async {
    const service = AdminService();
    final overview = await service.getOverview();
    final roles = await service.getRoleSummaries();
    final activities = await service.getRecentActivities();
    return {'overview': overview, 'roles': roles, 'activities': activities};
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      title: 'Admin',
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: _loadAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final overview = snapshot.data!['overview'] as dynamic;
            final roles = snapshot.data!['roles'] as List<dynamic>;
            final activities = snapshot.data!['activities'] as List<dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardSectionTitle('Resumen general'),
                AdminStatSection(overview: overview),
                const SizedBox(height: 16),

                const DashboardSectionTitle('Métricas globales'),
                FutureBuilder<Map<DateTime, double>>(
                  future: MetricsService.dailyTotalsGlobal('seller', DateTime.now().subtract(const Duration(days: 6)), DateTime.now()),
                  builder: (ctx, snap) {
                    if (!snap.hasData) return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                    final data = snap.data!;
                      final fmt = NumberFormat.simpleCurrency(locale: 'es_NI', name: 'C\$');
                    final total = data.values.fold<double>(0, (p, e) => p + e);
                    final best = data.entries.isEmpty ? null : data.entries.reduce((a,b) => a.value>=b.value?a:b).key;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ingresos (7d)', style: Theme.of(context).textTheme.bodySmall), const SizedBox(height:8), Text(fmt.format(total), style: Theme.of(context).textTheme.titleLarge)])),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Top día', style: Theme.of(context).textTheme.bodySmall), const SizedBox(height:8), Text(best != null ? '${best.day}/${best.month}' : '-')]))
                          ],
                        ),
                      ),
                    );
                  },
                ),


                const DashboardSectionTitle('Estado por rol'),
                AdminRoleSummarySection(summaries: roles.cast()),
                const SizedBox(height: 16),

                const DashboardSectionTitle('Actividad reciente'),
                AdminActivityList(activities: activities.cast()),
              ],
            );
          },
        ),
      ],
    );
  }
}
