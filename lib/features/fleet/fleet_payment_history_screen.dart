import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/fleet_payment.dart';
import 'services/fleet_jornada_service.dart';

class FleetPaymentHistoryScreen extends StatefulWidget {
  const FleetPaymentHistoryScreen({super.key});

  @override
  State<FleetPaymentHistoryScreen> createState() =>
      _FleetPaymentHistoryScreenState();
}

class _FleetPaymentHistoryScreenState extends State<FleetPaymentHistoryScreen> {
  final FleetJornadaService _service = FleetJornadaService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _service.load();
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  List<FleetPayment> get _payments => _service.getPaymentHistory();

  Future<void> _addPaymentDialog() async {
    final amountCtrl = TextEditingController();
    final bikesCtrl = TextEditingController(text: '1');
    String? error;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              title: const Text('Registrar pago'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto (C\$)',
                    ),
                  ),
                  TextField(
                    controller: bikesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Motos cubiertas',
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Este registro limpia la deuda actual.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final amount = double.tryParse(amountCtrl.text.trim());
                    final bikes = int.tryParse(bikesCtrl.text.trim());

                    if (amount == null || amount <= 0 || bikes == null ||
                        bikes <= 0) {
                      setInnerState(() {
                        error = 'Ingresa monto y motos válidos';
                      });
                      return;
                    }

                    _service.recordPayment(
                      amount: amount,
                      bikesCovered: bikes,
                      recordedBy: 'admin',
                    );
                    Navigator.of(ctx).pop(true);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pago registrado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de pagos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPaymentDialog,
        icon: const Icon(Icons.add_card),
        label: const Text('Registrar pago'),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? const Center(child: Text('Sin pagos registrados'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withAlpha(30),
                          child: const Icon(Icons.credit_card, color: Colors.green),
                        ),
                        title: Text(
                          'C\$${payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_dateFormat.format(payment.paidAt)),
                            Text('Motos cubiertas: ${payment.bikesCovered}'),
                            Text('Registrado por: ${payment.recordedBy}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
