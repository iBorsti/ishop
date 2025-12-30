import 'package:flutter/material.dart';

import '../services/fleet_jornada_service.dart';
import '../state/fleet_bike_jornada_controller.dart';
import '../models/fleet_bike_jornada.dart';
import '../services/fleet_service.dart';
import '../../../core/theme/app_colors.dart';

class FleetBikeJornadaCard extends StatefulWidget {
  final Map<String, dynamic> moto;
  final FleetJornadaService service;
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

  Color _statusColor(FleetJornadaStatus status, bool paid) {
    switch (status) {
      case FleetJornadaStatus.notStarted:
        return Colors.amber;
      case FleetJornadaStatus.active:
        return Colors.blue;
      case FleetJornadaStatus.closed:
        return paid ? Colors.green : Colors.orange;
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

        Widget actionButton;
        String title;
        String subtitle;

        switch (jornada.status) {
          case FleetJornadaStatus.notStarted:
            title = 'Jornada no iniciada';
            subtitle = 'Cuota diaria: C$${jornada.dailyFee}';
            actionButton = ElevatedButton(
              onPressed: () {
                _controller.startJornada();
                widget.onChanged();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Iniciar jornada'),
            );
            break;
          case FleetJornadaStatus.active:
            title = 'Jornada en curso';
            subtitle = 'Cuota del día: C$${jornada.dailyFee}';
            actionButton = ElevatedButton(
              onPressed: () {
                _controller.closeJornada(paid: false);
                widget.onChanged();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Cerrar jornada'),
            );
            break;
          case FleetJornadaStatus.closed:
            title = 'Jornada cerrada';
            if (jornada.paid) {
              subtitle = 'Cuota pagada';
              actionButton = const SizedBox.shrink();
            } else {
              subtitle = 'Cuota pendiente: C$${jornada.dailyFee}';
              actionButton = ElevatedButton(
                onPressed: () {
                  _controller.markAsPaid();
                  widget.onChanged();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text('Marcar como pagada'),
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      driver,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
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
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Deuda pendiente',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Días adeudados: ${debt.daysOwed}'),
                        Text('Total: C$${debt.totalAmount}'),
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
  final FleetJornadaService service;
  final List<Map<String, dynamic>> motos;

  const FleetBikeJornadaList({
    super.key,
    FleetJornadaService? service,
    List<Map<String, dynamic>>? motos,
  })  : service = service ?? FleetJornadaService(),
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
    await widget.service.load();
    for (final moto in widget.motos) {
      final id = moto['id'] as String;
      widget.service.getJornada(id);
      widget.service.getDebt(id);
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
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
          color: Colors.blueGrey[50],
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
                    Text('Deuda total: C$$totalDebt'),
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