import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/availability_provider.dart';
import '../../core/widgets/animated_entry.dart';
import '../../core/widgets/dashboard_scaffold.dart';
import '../../core/widgets/dashboard_section_title.dart';
import 'widgets/availability_toggle.dart';
import 'widgets/quota_progress_card.dart';
import 'widgets/delivery_stat_section.dart';
import 'widgets/jornada_status_card.dart';
import '../../core/services/mock_api.dart';
import 'delivery_payment_history_screen.dart';
import '../../core/alerts/alert_utils.dart';
import '../../core/alerts/widgets/alert_banner.dart';
import '../../core/alerts/models/alert_level.dart';
import '../../core/widgets/weekly_summary_card.dart';
import 'models/delivery_weekly_summary.dart';
import '../../core/utils/week_utils.dart';
import 'services/delivery_jornada_repository.dart';
import 'services/delivery_jornada_factory.dart';
import '../../core/config/app_env.dart';
import '../../core/widgets/confirm_dialog.dart';

class DeliveryDashboard extends ConsumerStatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  ConsumerState<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends ConsumerState<DeliveryDashboard> {
  final DeliveryJornadaRepository _jornadaService =
      buildDeliveryJornadaRepository();
  bool loading = true;
  String? error;
  Map<String, dynamic>? stats;
  bool _alertLoading = true;
  int _daysOwed = 0;
  DeliveryWeeklySummary? _weeklySummary;
  DeliveryWeeklySummary? _prevWeeklySummary;
  String? _weekLabel;
  bool _resetting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await fetchDeliveryStats();
      await _loadAlerts();
      await _loadWeeklySummary();
      setState(() {
        stats = result;
        loading = false;
      });
    } catch (e) {
      await _loadAlerts();
      await _loadWeeklySummary();
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _loadAlerts() async {
    await _jornadaService.load();
    if (!mounted) return;
    setState(() {
      _daysOwed = _jornadaService.getDebt().daysOwed;
      _alertLoading = false;
    });
  }

  Future<void> _loadWeeklySummary() async {
    await _jornadaService.load();
    if (!mounted) return;
    setState(() {
      _weeklySummary = _jornadaService.getWeeklySummary(DateTime.now());
      _prevWeeklySummary = _jornadaService.getWeeklySummary(
        DateTime.now().subtract(const Duration(days: 7)),
      );
      _weekLabel = weekRangeLabel(DateTime.now());
    });
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _alertLoading = true;
    });
    await _loadAlerts();
    await _loadWeeklySummary();
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
      await _jornadaService.resetDemoData();
      await _load();
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

  String _alertMessage(int days, AlertLevel level) {
    if (days <= 0) return '';
    switch (level) {
      case AlertLevel.info:
        return days == 1
            ? 'Tienes 1 jornada pendiente'
            : 'Tienes $days jornadas pendientes';
      case AlertLevel.warning:
        return 'Tu deuda está aumentando ($days jornadas pendientes)';
      case AlertLevel.critical:
        return 'Revisa tus pagos para evitar acumulación ($days jornadas pendientes)';
      case AlertLevel.none:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const DashboardScaffold(
        title: 'Delivery',
        children: [
          SizedBox(height: 32),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (error != null) {
      return DashboardScaffold(
        title: 'Delivery',
        children: [
          const SizedBox(height: 32),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No se pudieron cargar los datos'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final available = ref.watch(availabilityProvider);
    final level = resolveAlertLevel(daysOwed: _daysOwed);
    final message = _alertMessage(_daysOwed, level);
    final summary = _weeklySummary;
    final prev = _prevWeeklySummary;
    return DashboardScaffold(
      title: 'Delivery',
      children: [
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
        if (!_alertLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Tooltip(
              message: message,
              child: AlertBanner(
                level: level,
                message: message,
              ),
            ),
          ),
        if (summary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WeeklySummaryCard(
              title: 'Resumen semanal',
              lines: [
                'Trabajaste ${summary.worked} día(s).',
                'Pagaste ${summary.paid}.',
                'Tienes ${summary.pending} pendiente(s).',
              ],
              subtitle: _weekLabel,
              highlightAmount: summary.pendingAmount > 0
                  ? 'Deuda semanal: C\$${summary.pendingAmount.toStringAsFixed(2)}'
                  : null,
              comparison: prev != null
                  ? 'Semana anterior: trabajaste ${prev.worked}, pendientes ${prev.pending} (C\$${prev.pendingAmount.toStringAsFixed(2)})'
                  : null,
            ),
          ),
        JornadaStatusCard(onChanged: _refreshAlerts),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeliveryPaymentHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Pagos'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ),
        const SizedBox(height: 16),
        const DashboardSectionTitle('Estado'),
        const AnimatedEntry(
          delay: Duration(milliseconds: 100),
          child: AvailabilityToggle(),
        ),
        // Indicador visual global de disponibilidad
        const SizedBox(height: 12),
        Row(
          children: [
            Semantics(
              label: 'Indicador de disponibilidad',
              value: available ? 'Disponible' : 'No disponible',
              toggled: available,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: available
                      ? Colors.green.withAlpha(40)
                      : Colors.grey.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    AnimatedScale(
                      scale: available ? 1.0 : 0.95,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        available ? Icons.check_circle : Icons.pause_circle,
                        color: available ? Colors.green : Colors.grey,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      available ? 'Disponible' : 'No disponible',
                      style: TextStyle(
                        color: available ? Colors.green[800] : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: available
                  ? 'Desactivar disponibilidad'
                  : 'Activar disponibilidad',
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(availabilityProvider.notifier).toggle(),
                icon: Icon(
                  available ? Icons.toggle_on : Icons.toggle_off,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(available ? 'Desactivar' : 'Activar'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        if (loading) ...[
          const SizedBox(height: 8),
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
        ] else if (error != null) ...[
          Center(
            child: Column(
              children: [
                Text('Error: $error'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ] else ...[
          const DashboardSectionTitle('Métricas'),
          AnimatedEntry(
            delay: const Duration(milliseconds: 200),
            child: DeliveryStatSection(data: stats!),
          ),
          const SizedBox(height: 12),
          const DashboardSectionTitle('Cuota diaria'),
          AnimatedEntry(
            delay: const Duration(milliseconds: 300),
            child: QuotaProgressCard(
              quota: stats!['quota']['quota'],
              earned: stats!['quota']['earned'],
            ),
          ),
        ],
      ],
    );
  }
}
