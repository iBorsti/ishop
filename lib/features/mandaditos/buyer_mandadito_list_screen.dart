import 'package:flutter/material.dart';

import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/auth/widgets/role_guard.dart';
import 'mandadito.dart';
import 'mandadito_service.dart';

class BuyerMandaditoListScreen extends StatefulWidget {
  const BuyerMandaditoListScreen({super.key});

  @override
  State<BuyerMandaditoListScreen> createState() => _BuyerMandaditoListScreenState();
}

class _BuyerMandaditoListScreenState extends State<BuyerMandaditoListScreen> {
  late Future<List<Mandadito>> _future;
  String _ownerId = '';

  @override
  void initState() {
    super.initState();
    _ownerId = AuthController.instance.user?.id ?? '';
    _future = _load();
  }

  Future<List<Mandadito>> _load() async {
    if (_ownerId.isEmpty) return [];
    return MandaditoService.getMyMandaditos(_ownerId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.buyer,
      allowIfUnauthenticated: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mis mandaditos')),
        body: FutureBuilder<List<Mandadito>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_ownerId.isEmpty) {
              return const Center(
                child: Text('Inicia sesión como comprador para ver tus mandaditos'),
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  children: const [
                    SizedBox(height: 140),
                    Center(child: Text('Aún no has publicado mandaditos')),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final item = items[i];
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
                              _StatusChip(status: item.status),
                              const SizedBox(width: 8),
                              Text(item.urgent ? 'Urgente' : 'Normal'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('${item.origin} → ${item.destination}'),
                          if (item.budget != null) ...[
                            const SizedBox(height: 6),
                            Text('Presupuesto: C\$ ${item.budget!.toStringAsFixed(0)}'),
                          ],
                          if (item.status == MandaditoStatus.taken)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Tu mandadito fue tomado',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          if (item.status == MandaditoStatus.completed)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Completado',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MandaditoStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case MandaditoStatus.open:
        color = Colors.blue.shade100;
        text = 'Abierto';
        break;
      case MandaditoStatus.taken:
        color = Colors.orange.shade100;
        text = 'Tomado';
        break;
      case MandaditoStatus.completed:
        color = Colors.green.shade100;
        text = 'Completado';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}
