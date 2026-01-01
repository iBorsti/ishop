import 'package:flutter/material.dart';

import '../../core/auth/widgets/role_guard.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/widgets/confirm_dialog.dart';
import 'mandadito.dart';
import 'mandadito_service.dart';

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
            final data = snapshot.data ?? const DeliveryMandaditoLists(open: [], mine: []);
            if (data.open.isEmpty && data.mine.isEmpty) {
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
                  if (data.mine.isNotEmpty) ...[
                    const Text(
                      'Tomados por ti',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...data.mine.map((item) => _MandaditoCard(
                          item: item,
                          primaryActionLabel: 'Marcar como completado',
                          onPrimaryAction: _completing ? null : () => _complete(item.id),
                          actionColor: Colors.green,
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (data.open.isNotEmpty) ...[
                    const Text(
                      'Abiertos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...data.open.map((item) => _MandaditoCard(
                          item: item,
                          primaryActionLabel: 'Aceptar',
                          onPrimaryAction: _taking ? null : () => _confirmAndTake(item.id),
                        )),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('${item.origin} → ${item.destination}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: item.urgent
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.urgent ? 'Urgente' : 'Normal',
                    style: TextStyle(
                      color: item.urgent
                          ? Colors.orange.shade800
                          : Colors.green.shade800,
                    ),
                  ),
                ),
                if (item.budget != null) ...[
                  const SizedBox(width: 8),
                  Text('Presupuesto: C\$ ${item.budget!.toStringAsFixed(0)}'),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimaryAction,
                style: actionColor != null
                    ? ElevatedButton.styleFrom(backgroundColor: actionColor)
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
