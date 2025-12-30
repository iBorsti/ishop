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
import 'services/delivery_jornada_service.dart';

class DeliveryDashboard extends ConsumerStatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  ConsumerState<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends ConsumerState<DeliveryDashboard> {
  final DeliveryJornadaService _jornadaService = DeliveryJornadaService();
  bool loading = true;
  String? error;
  Map<String, dynamic>? stats;
  bool _alertLoading = true;
  int _daysOwed = 0;

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
      setState(() {
        stats = result;
        loading = false;
      });
    } catch (e) {
      await _loadAlerts();
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

  Future<void> _refreshAlerts() async {
    setState(() {
      _alertLoading = true;
    });
    await _loadAlerts();
  }

  String _alertMessage(int days) {
    if (days <= 0) return '';
    if (days == 1) return 'Tienes 1 jornada pendiente';
    if (days >= 5) return 'Tienes $days jornadas pendientes. Revisa tus pagos.';
    return 'Tienes $days jornadas pendientes';
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(availabilityProvider);
    final level = resolveAlertLevel(daysOwed: _daysOwed);
    return DashboardScaffold(
      title: 'Delivery',
      children: [
        if (!_alertLoading)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AlertBanner(
              level: level,
              message: _alertMessage(_daysOwed),
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
