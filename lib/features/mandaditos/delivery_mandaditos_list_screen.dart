import 'package:flutter/material.dart';

import '../../core/auth/widgets/role_guard.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/widgets/confirm_dialog.dart';
import 'mandadito.dart';
import 'mandadito_service.dart';
import '../../core/theme/app_colors.dart';

class DeliveryMandaditosListScreen extends StatefulWidget {
  const DeliveryMandaditosListScreen({super.key});

  @override
  State<DeliveryMandaditosListScreen> createState() =>
      _DeliveryMandaditosListScreenState();
}

class _DeliveryMandaditosListScreenState
    extends State<DeliveryMandaditosListScreen> {
  late Future<DeliveryMandaditoLists> _future;
  bool _taking = false;
  bool _completing = false;
  String _deliveryId = '';

  @override
  void initState() {
    super.initState();
    _deliveryId = AuthController.instance.user?.id ?? '';
    _future = _load();
  }

  Future<DeliveryMandaditoLists> _load() {
    return MandaditoService.getListsForDelivery(_deliveryId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _confirmAndTake(String id) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: '¿Aceptar este mandadito?',
      message: 'Al aceptarlo te comprometes a coordinar con el comprador.',
      confirmText: 'Aceptar',
    );
    if (confirmed != true) return;
    await _take(id);
  }

  Future<void> _take(String id) async {
    if (_taking) return;
    if (_deliveryId.isEmpty) return;
    setState(() => _taking = true);
    final ok = await MandaditoService.takeMandadito(
      id: id,
      takenBy: _deliveryId,
    );
    if (!mounted) return;
    setState(() => _taking = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya no está disponible')),
      );
      _refresh();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mandadito aceptado')),
    );
    _refresh();
  }

  Future<void> _complete(String id) async {
    if (_completing) return;
    if (_deliveryId.isEmpty) return;
    setState(() => _completing = true);
    final ok = await MandaditoService.completeMandadito(
      id: id,
      requesterId: _deliveryId,
    );
    if (!mounted) return;
    setState(() => _completing = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo completar')),
      );
      _refresh();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marcado como completado')),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.delivery,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mandaditos abiertos')),
        body: FutureBuilder<DeliveryMandaditoLists>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_deliveryId.isEmpty) {
              return const Center(
                child: Text('Inicia sesión como delivery para continuar'),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: TextButton(
                  onPressed: _refresh,
                  child: const Text('Reintentar'),
                ),
              );
            }
            final data = snapshot.data ??
                const DeliveryMandaditoLists(open: [], mine: [], completed: []);
            if (data.open.isEmpty && data.mine.isEmpty && data.completed.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  children: const [
                    SizedBox(height: 140),
                    Center(child: Text('No hay mandaditos abiertos ahora')),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DeliverySummary(
                    mineCount: data.mine.length,
                    openCount: data.open.length,
                    completedCount: data.completed.length,
                  ),
                  const SizedBox(height: 16),
                  if (data.mine.isNotEmpty) ...[
                    const _SectionTitle('Tomados por ti'),
                    const SizedBox(height: 8),
                    ...data.mine.map(
                      (item) => _MandaditoCard(
                        item: item,
                        primaryActionLabel: 'Marcar como completado',
                        onPrimaryAction:
                            _completing ? null : () => _complete(item.id),
                        actionColor: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (data.completed.isNotEmpty) ...[
                    const _SectionTitle('Completados'),
                    const SizedBox(height: 8),
                    ...data.completed.map(
                      (item) => _MandaditoCard(
                        item: item,
                        primaryActionLabel: 'Completado',
                        onPrimaryAction: null,
                        actionColor: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (data.open.isNotEmpty) ...[
                    const _SectionTitle('Abiertos'),
                    const SizedBox(height: 8),
                    ...data.open.map(
                      (item) => _MandaditoCard(
                        item: item,
                        primaryActionLabel: 'Aceptar',
                        onPrimaryAction:
                            _taking ? null : () => _confirmAndTake(item.id),
                        actionColor: AppColors.turquoise,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MandaditoCard extends StatelessWidget {
  final Mandadito item;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final Color? actionColor;

  const _MandaditoCard({
    required this.item,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.description,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                _StatusPill(
                  label: item.urgent ? 'Urgente' : 'Normal',
                  color: item.urgent
                      ? AppColors.warningYellow
                      : AppColors.turquoise,
                  background: item.urgent
                      ? AppColors.warningYellow.withAlpha(24)
                      : AppColors.turquoise.withAlpha(18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.place_outlined,
              iconColor: AppColors.turquoise,
              label: item.origin,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.flag_outlined,
              iconColor: AppColors.secondaryBlue,
              label: item.destination,
            ),
            if (item.budget != null) ...[
              const SizedBox(height: 10),
              _InfoPill(
                icon: Icons.payments_outlined,
                text: 'Presupuesto: C\$ ${item.budget!.toStringAsFixed(0)}',
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: onPrimaryAction == null
                  ? Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withAlpha(18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: AppColors.successGreen),
                          SizedBox(width: 8),
                          Text(
                            'Completado',
                            style: TextStyle(color: AppColors.textGray),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onPrimaryAction,
                      style: actionColor != null
                          ? ElevatedButton.styleFrom(
                              backgroundColor: actionColor,
                              foregroundColor: Colors.white,
                            )
                          : null,
                      child: Text(primaryActionLabel),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.turquoise.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.turquoise),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DeliverySummary extends StatelessWidget {
  final int mineCount;
  final int openCount;
  final int completedCount;

  const _DeliverySummary({
    required this.mineCount,
    required this.openCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _SummaryItem(
              label: 'Tomados',
              value: mineCount,
              color: AppColors.turquoise,
            ),
            _SummaryItem(
              label: 'Abiertos',
              value: openCount,
              color: AppColors.secondaryBlue,
            ),
            _SummaryItem(
              label: 'Completados',
              value: completedCount,
              color: AppColors.successGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(color: AppColors.navy),
    );
  }
}
