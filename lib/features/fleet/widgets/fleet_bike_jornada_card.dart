import 'package:flutter/material.dart';

import '../services/fleet_jornada_repository.dart';
import '../state/fleet_bike_jornada_controller.dart';
import '../models/fleet_bike_jornada.dart';
import '../services/fleet_service.dart';
import '../services/fleet_jornada_factory.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/alerts/alert_utils.dart';
import '../../../core/alerts/models/alert_level.dart';
import '../../../core/widgets/confirm_dialog.dart';

class FleetBikeJornadaCard extends StatefulWidget {
  final Map<String, dynamic> moto;
  final FleetJornadaRepository service;
  final VoidCallback onChanged;

  const FleetBikeJornadaCard({
    super.key,
    required this.moto,
    required this.service,
    required this.onChanged,
  });

  @override
  State<FleetBikeJornadaCard> createState() => _FleetBikeJornadaCardState();
}

class _FleetBikeJornadaCardState extends State<FleetBikeJornadaCard> {
  late final FleetBikeJornadaController _controller;
  bool _initialized = false;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = FleetBikeJornadaController(
      widget.service,
      bikeId: widget.moto['id'] as String,
    );
    _initOnce();
  }

  Future<void> _initOnce() async {
    if (_initialized) return;
    _initialized = true;
    await _controller.init();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Color _statusColor(FleetJornadaStatus status, bool paid) {
    switch (status) {
      case FleetJornadaStatus.notStarted:
        return AppColors.warningYellow; // pendiente/inactivo
      case FleetJornadaStatus.active:
        return AppColors.turquoise; // en curso
      case FleetJornadaStatus.closed:
        return paid ? AppColors.successGreen : AppColors.coral;
    }
  }

  Color _alertColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return AppColors.coral;
      case AlertLevel.warning:
        return AppColors.warningYellow;
      case AlertLevel.info:
        return AppColors.turquoise;
      case AlertLevel.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alias = widget.moto['alias'] ?? '';
    final driver = widget.moto['driver'] ?? '—';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.loading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
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
          case FleetJornadaStatus.notStarted:
            title = 'Jornada no iniciada';
            subtitle = 'Cuota diaria: C\$${jornada.dailyFee}';
            actionButton = ElevatedButton(
              onPressed: () {
                _controller.startJornada();
                _showMessage('Jornada iniciada para ${widget.moto['id']}');
                widget.onChanged();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.turquoise,
                foregroundColor: Colors.white,
              ),
              child: const Text('Iniciar jornada'),
            );
            break;
          case FleetJornadaStatus.active:
            title = 'Jornada en curso';
            subtitle = 'Cuota del día: C\$${jornada.dailyFee}';
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
                        _showMessage('Jornada cerrada para ${widget.moto['id']}');
                        widget.onChanged();
                      } catch (_) {
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No se pudo cerrar la jornada de la moto. Intenta de nuevo.',
                            ),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _actionLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.turquoise,
                foregroundColor: Colors.white,
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
          case FleetJornadaStatus.closed:
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
                          _showMessage('Cuota pagada para ${widget.moto['id']}');
                          widget.onChanged();
                        } catch (_) {
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'No se pudo registrar el pago de la moto. Intenta de nuevo.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _actionLoading = false);
                        }
                      },
                      style: AppButtonStyles.success,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Expanded(
                      child: Text(
                        '${widget.moto['id']} • $alias',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Text(
                      driver,
                      style: const TextStyle(color: AppColors.textGray),
                    ),
                    if (alertLevel != AlertLevel.none) ...[
                      const SizedBox(width: 8),
                      Tooltip(
                        message:
                            'Esta moto lleva ${debt.daysOwed} día(s) sin pagar',
                        child: Icon(
                          Icons.report_gmailerrorred,
                          color: alertColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.textGray),
                ),
                const SizedBox(height: 12),
                if (debt.totalAmount > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.coral.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.coral.withAlpha(120)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.coral,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Deuda pendiente',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.coral,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Días adeudados: ${debt.daysOwed}',
                          style: const TextStyle(color: AppColors.navy),
                        ),
                        Text(
                          'Total: C\$${debt.totalAmount}',
                          style: const TextStyle(color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                actionButton,
              ],
            ),
          ),
        );
      },
    );
  }
}

class FleetBikeJornadaList extends StatefulWidget {
  final FleetJornadaRepository service;
  final List<Map<String, dynamic>> motos;
  final bool autoLoad;
  final VoidCallback? onChanged;

  FleetBikeJornadaList({
    super.key,
    FleetJornadaRepository? service,
    List<Map<String, dynamic>>? motos,
    this.autoLoad = true,
    this.onChanged,
  }) : service = service ?? buildFleetJornadaRepository(),
       motos = motos ?? FleetService.getMotos();

  @override
  State<FleetBikeJornadaList> createState() => _FleetBikeJornadaListState();
}

class _FleetBikeJornadaListState extends State<FleetBikeJornadaList> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.autoLoad) {
      await widget.service.load();
      for (final moto in widget.motos) {
        final id = moto['id'] as String;
        widget.service.getJornada(id);
        widget.service.getDebt(id);
      }
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final totalDebt = widget.service.totalDebtAmount();
    final daysOwed = widget.service.totalDaysOwed();
    final bikes = widget.motos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de jornadas',
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
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.motos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final moto = widget.motos[index];
            return FleetBikeJornadaCard(
              moto: moto,
              service: widget.service,
              onChanged: _refresh,
            );
          },
        ),
      ],
    );
  }
}
