import 'package:flutter/material.dart';
import 'services/fleet_jornada_repository.dart';
import 'services/fleet_jornada_factory.dart';
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
import '../../core/config/app_env.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/metrics/metrics_service.dart';

class FleetDashboard extends StatefulWidget {
  const FleetDashboard({super.key});

  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  final FleetJornadaRepository _service = buildFleetJornadaRepository();
  late final List<Map<String, dynamic>> _motos;
  bool _loading = true;
  String? _error;
  FleetWeeklySummary? _weeklySummary;
  FleetWeeklySummary? _prevWeeklySummary;
  String? _weekLabel;
  bool _resetting = false;

  @override
  void initState() {
    super.initState();
    _motos = FleetService.getMotos();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
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
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No se pudieron cargar los datos';
          _loading = false;
        });
      }
    }
  }

  Future<void> _resetDemo() async {
    if (!AppConfig.isDemo || _resetting) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Resetear datos demo',
      message: 'Esta acción borrará todos los datos demo. ¿Deseas continuar?',
      confirmText: 'Borrar',
    );
    if (confirmed != true) return;
    setState(() => _resetting = true);
    try {
      await _service.resetDemoData();
      await _init();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No se pudo resetear los datos demo. Intenta de nuevo.'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  Widget _jornadaSummaryCard() {
    final totalDebt = _service.totalDebtAmount();
    final daysOwed = _service.totalDaysOwed();
    final bikes = _motos.length;

    return Card(
      color: AppColors.background,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Motos: $bikes',
                  style: const TextStyle(color: AppColors.textGray),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Días adeudados: $daysOwed',
                  style: const TextStyle(color: AppColors.warningYellow),
                ),
                Text(
                  'Deuda total: C\$$totalDebt',
                  style: const TextStyle(color: AppColors.coral),
                ),
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

    if (_error != null) {
      return DashboardScaffold(
        title: 'Flota',
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _init,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return DashboardScaffold(
      title: 'Flota',
      children: [
        const DashboardSectionTitle('Métricas'),
        SizedBox(
          height: 160,
          child: FutureBuilder<Map<DateTime, double>>(
            future: MetricsService.dailyTotals('fleet', AuthController.instance.user?.id ?? '', DateTime.now().subtract(const Duration(days: 6)), DateTime.now()),
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final data = snap.data ?? {};
              final entries = data.entries.toList();
              return ListView(
                scrollDirection: Axis.horizontal,
                children: entries.map((e) => Card(margin: const EdgeInsets.all(8), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Text('${e.key.day}/${e.key.month}'), const SizedBox(height:8), Text('C\$${e.value.toStringAsFixed(0)}')] )))).toList(),
              );
            },
          ),
        ),
        if (AppConfig.isDemo)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _resetting ? null : _resetDemo,
              icon: _resetting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restart_alt, color: Colors.red),
              label: Text(
                _resetting ? 'Borrando...' : 'Resetear datos demo',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
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
            style: AppButtonStyles.success,
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
