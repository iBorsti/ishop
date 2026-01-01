import 'package:flutter/material.dart';

import '../../core/auth/widgets/role_guard.dart';
import '../../core/auth/models/app_user.dart';
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
  late Future<List<Mandadito>> _future;
  bool _taking = false;

  @override
  void initState() {
    super.initState();
    _future = MandaditoService.getOpenMandaditos();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = MandaditoService.getOpenMandaditos();
    });
  }

  Future<void> _take(String id) async {
    if (_taking) return;
    setState(() => _taking = true);
    final ok = await MandaditoService.takeMandadito(id);
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

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.delivery,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mandaditos abiertos')),
        body: FutureBuilder<List<Mandadito>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: TextButton(
                  onPressed: _refresh,
                  child: const Text('Reintentar'),
                ),
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return const Center(
                child: Text('No hay mandaditos abiertos ahora'),
              );
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
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
                                Text(
                                  'Presupuesto: C\$ ${item.budget!.toStringAsFixed(0)}',
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _taking ? null : () => _take(item.id),
                              child: const Text('Aceptar'),
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
