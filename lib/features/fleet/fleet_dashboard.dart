import 'package:flutter/material.dart';
import 'services/fleet_jornada_service.dart';
import 'services/fleet_service.dart';
import 'widgets/fleet_stat_section.dart';
import 'widgets/fleet_map_placeholder.dart';
import 'widgets/moto_status_card.dart';
import 'widgets/fleet_bike_jornada_card.dart';
import 'widgets/fleet_financial_summary_card.dart';
import '../../core/widgets/dashboard_scaffold.dart';
import '../../core/widgets/dashboard_section_title.dart';
import 'fleet_payment_history_screen.dart';

class FleetDashboard extends StatefulWidget {
  const FleetDashboard({super.key});

  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  final FleetJornadaService _service = FleetJornadaService();
  late final List<Map<String, dynamic>> _motos;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _motos = FleetService.getMotos();
    _init();
  }

  Future<void> _init() async {
    await _service.load();
    for (final moto in _motos) {
      final id = moto['id'] as String;
      _service.getJornada(id);
      _service.getDebt(id);
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _jornadaSummaryCard() {
    final totalDebt = _service.totalDebtAmount();
    final daysOwed = _service.totalDaysOwed();
    final bikes = _motos.length;

    return Card(
      color: Colors.blueGrey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jornadas hoy',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Motos: $bikes'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Días adeudados: $daysOwed'),
                Text('Deuda total: C\$${totalDebt}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final stats = FleetService.getStats();

    if (_loading) {
      return const DashboardScaffold(
        title: 'Flota',
        children: [
          SizedBox(height: 32),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    return DashboardScaffold(
      title: 'Flota',
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FleetPaymentHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Pagos'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ),
        const SizedBox(height: 12),
        const DashboardSectionTitle('Finanzas de hoy'),
        FleetFinancialSummaryCard(summary: _service.getFinancialSummary()),
        const SizedBox(height: 12),
        _jornadaSummaryCard(),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Resumen rápido'),
        FleetStatSection(stats: stats),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Jornadas por moto'),
        FleetBikeJornadaList(
          service: _service,
          motos: _motos,
          autoLoad: false,
          onChanged: _refresh,
        ),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Mapa'),
        const FleetMapPlaceholder(),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Motos'),
        MotoStatusList(),
      ],
    );
  }
}
