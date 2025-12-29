import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/availability_provider.dart';
import '../../core/widgets/animated_entry.dart';
// removed unused import
import 'widgets/availability_toggle.dart';
import 'widgets/quota_progress_card.dart';
import 'widgets/delivery_stat_section.dart';
import '../../core/services/mock_api.dart';

class DeliveryDashboard extends ConsumerStatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  ConsumerState<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends ConsumerState<DeliveryDashboard> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? stats;

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
      setState(() {
        stats = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(availabilityProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AnimatedEntry(
              delay: Duration(milliseconds: 100),
              child: AvailabilityToggle(),
            ),

            // Indicador visual global de disponibilidad (mejorado para accesibilidad)
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
                            color: available
                                ? Colors.green[800]
                                : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Acción rápida para alternar disponibilidad
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
              AnimatedEntry(
                delay: const Duration(milliseconds: 200),
                child: DeliveryStatSection(data: stats!),
              ),
              const SizedBox(height: 12),
              AnimatedEntry(
                delay: const Duration(milliseconds: 300),
                child: QuotaProgressCard(
                  quota: stats!['quota']['quota'],
                  earned: stats!['quota']['earned'],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
