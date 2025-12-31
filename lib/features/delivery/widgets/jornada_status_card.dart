import 'package:flutter/material.dart';

import '../state/delivery_jornada_controller.dart';
import '../models/delivery_jornada.dart';
import '../services/delivery_jornada_repository.dart';
import '../services/delivery_jornada_factory.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/alerts/alert_utils.dart';
import '../../../core/alerts/models/alert_level.dart';
import '../../../core/widgets/confirm_dialog.dart';

class JornadaStatusCard extends StatefulWidget {
  final VoidCallback? onChanged;

  const JornadaStatusCard({super.key, this.onChanged});

  @override
  State<JornadaStatusCard> createState() => _JornadaStatusCardState();
}

class _JornadaStatusCardState extends State<JornadaStatusCard> {
  late final DeliveryJornadaController _controller;
  bool _initialized = false;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = DeliveryJornadaController(buildDeliveryJornadaRepository());
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

  Color _alertColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.deepOrange;
      case AlertLevel.info:
        return Colors.orange;
      case AlertLevel.none:
        return Colors.transparent;
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
        final alertLevel = resolveAlertLevel(daysOwed: debt.daysOwed);
        final alertColor = _alertColor(alertLevel);

        Widget actionButton;
        String title;
        String subtitle;

        switch (jornada.status) {
          case JornadaStatus.notStarted:
            title = 'Jornada no iniciada';
            subtitle = 'Pulsa para iniciar tu jornada';
            actionButton = ElevatedButton(
              onPressed: () {
                _controller.startJornada();
                widget.onChanged?.call();
              },
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
              onPressed: _actionLoading
                  ? null
                  : () async {
                      final confirmed = await showConfirmDialog(
                        context: context,
                        title: 'Cerrar jornada',
                        message:
                            '¿Seguro que deseas cerrar la jornada? Esta acción no se puede deshacer.',
                      );
                      if (confirmed != true) return;
                      if (_actionLoading) return;
                      setState(() => _actionLoading = true);
                      try {
                        _controller.closeJornada(paid: false);
                        widget.onChanged?.call();
                      } finally {
                        if (mounted) setState(() => _actionLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: _actionLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cerrar jornada'),
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
                onPressed: _actionLoading
                    ? null
                    : () async {
                        final confirmed = await showConfirmDialog(
                          context: context,
                          title: 'Registrar pago',
                          message:
                              'Este registro limpiará la deuda actual. ¿Deseas continuar?',
                        );
                        if (confirmed != true) return;
                        if (_actionLoading) return;
                        setState(() => _actionLoading = true);
                        try {
                          _controller.markAsPaid();
                          widget.onChanged?.call();
                        } finally {
                          if (mounted) setState(() => _actionLoading = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: _actionLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Marcar como pagada'),
              );
            }
            break;
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: alertLevel == AlertLevel.none
                ? BorderSide.none
                : BorderSide(color: alertColor.withAlpha(160), width: 1.4),
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
                    if (alertLevel != AlertLevel.none) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.report_gmailerrorred,
                        color: alertColor,
                        size: 18,
                      ),
                    ],
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
