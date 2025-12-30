import 'package:flutter/material.dart';

import '../state/delivery_jornada_controller.dart';
import '../models/delivery_jornada.dart';
import '../services/delivery_jornada_service.dart';
import '../../../core/theme/app_colors.dart';

class JornadaStatusCard extends StatefulWidget {
  const JornadaStatusCard({super.key});

  @override
  State<JornadaStatusCard> createState() => _JornadaStatusCardState();
}

class _JornadaStatusCardState extends State<JornadaStatusCard> {
  late final DeliveryJornadaController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = DeliveryJornadaController(DeliveryJornadaService());
    _initOnce();
  }

  Future<void> _initOnce() async {
    if (_initialized) return;
    _initialized = true;
    await _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor(JornadaStatus status, bool paid) {
    switch (status) {
      case JornadaStatus.notStarted:
        return Colors.amber;
      case JornadaStatus.active:
        return Colors.blue;
      case JornadaStatus.closed:
        return paid ? Colors.green : Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.loading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final jornada = _controller.jornada;
        final debt = _controller.debt;
        final color = _statusColor(jornada.status, jornada.paid);

        Widget actionButton;
        String title;
        String subtitle;

        switch (jornada.status) {
          case JornadaStatus.notStarted:
            title = 'Jornada no iniciada';
            subtitle = 'Pulsa para iniciar tu jornada';
            actionButton = ElevatedButton(
              onPressed: _controller.startJornada,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Iniciar jornada'),
            );
            break;
          case JornadaStatus.active:
            title = 'Jornada en curso';
            subtitle =
                'Cuota del día: C\$${jornada.dailyFee} • Estado: Pendiente';
            actionButton = ElevatedButton(
              onPressed: () => _controller.closeJornada(paid: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Cerrar jornada'),
            );
            break;
          case JornadaStatus.closed:
            title = 'Jornada cerrada';
            if (jornada.paid) {
              subtitle = 'Cuota pagada';
              actionButton = const SizedBox.shrink();
            } else {
              subtitle = 'Cuota pendiente: C\$${jornada.dailyFee}';
              actionButton = ElevatedButton(
                onPressed: _controller.markAsPaid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text('Marcar como pagada'),
              );
            }
            break;
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (debt.totalAmount > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withAlpha(80)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Deuda pendiente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Días adeudados: ${debt.daysOwed}'),
                        Text('Total: C\$${debt.totalAmount}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle),
                const SizedBox(height: 12),
                actionButton,
              ],
            ),
          ),
        );
      },
    );
  }
}
