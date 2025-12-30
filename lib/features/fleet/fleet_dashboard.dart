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
import '../../core/alerts/alert_utils.dart';
import '../../core/alerts/widgets/alert_banner.dart';
import '../../core/alerts/models/alert_level.dart';
import '../../core/widgets/weekly_summary_card.dart';
import 'models/fleet_weekly_summary.dart';
import '../../core/utils/week_utils.dart';

class FleetDashboard extends StatefulWidget {
  const FleetDashboard({super.key});

  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  final FleetJornadaService _service = FleetJornadaService();
  late final List<Map<String, dynamic>> _motos;
  bool _loading = true;
  FleetWeeklySummary? _weeklySummary;
  FleetWeeklySummary? _prevWeeklySummary;
  String? _weekLabel;

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
    _weeklySummary = _service.getWeeklySummary(DateTime.now());
    _prevWeeklySummary =
        _service.getWeeklySummary(DateTime.now().subtract(const Duration(days: 7)));
    _weekLabel = weekRangeLabel(DateTime.now());
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
        Builder(builder: (context) {
          final daysOwed = _service.totalDaysOwed();
          final level = resolveAlertLevel(daysOwed: daysOwed);
          final bikesInDebt = _service.bikesWithDebtCount();
          final debt = _service.totalDebtAmount();
          if (level == AlertLevel.none || bikesInDebt == 0) {
            return const SizedBox.shrink();
          }
          String message;
          switch (level) {
            case AlertLevel.info:
              message = '$bikesInDebt motos con deuda • Deuda: C\$$debt';
              break;
            case AlertLevel.warning:
              message =
                  'Tu deuda de flota está aumentando: $bikesInDebt motos • C\$$debt';
              break;
            case AlertLevel.critical:
              message =
                  'Revisa pagos: $bikesInDebt motos con deuda • Deuda: C\$$debt';
              break;
            case AlertLevel.none:
              message = '';
              break;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AlertBanner(level: level, message: message),
          );
        }),
        if (_weeklySummary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WeeklySummaryCard(
              title: 'Resumen semanal',
              lines: [
                'Motos activas: ${_weeklySummary!.activeBikes}',
                'Jornadas de moto: ${_weeklySummary!.bikeJornadas}',
                'Días con deuda: ${_weeklySummary!.debtDays}',
              ],
              subtitle: _weekLabel,
              highlightAmount: _weeklySummary!.debtAmount > 0
                  ? 'Deuda semanal: C\$${_weeklySummary!.debtAmount.toStringAsFixed(2)}'
                  : null,
              comparison: _prevWeeklySummary != null
                  ? 'Semana anterior: jornadas ${_prevWeeklySummary!.bikeJornadas}, deuda C\$${_prevWeeklySummary!.debtAmount.toStringAsFixed(2)}'
                  : null,
            ),
          ),
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
