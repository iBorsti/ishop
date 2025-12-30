import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/delivery_payment.dart';
import 'services/delivery_jornada_repository.dart';
import 'services/delivery_jornada_factory.dart';
import '../../core/widgets/confirm_dialog.dart';

class DeliveryPaymentHistoryScreen extends StatefulWidget {
  const DeliveryPaymentHistoryScreen({super.key});

  @override
  State<DeliveryPaymentHistoryScreen> createState() =>
      _DeliveryPaymentHistoryScreenState();
}

class _DeliveryPaymentHistoryScreenState
    extends State<DeliveryPaymentHistoryScreen> {
  final DeliveryJornadaRepository _service = buildDeliveryJornadaRepository();
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

  List<DeliveryPayment> get _payments => _service.getPaymentHistory();

  Future<void> _addPaymentDialog() async {
    final amountCtrl = TextEditingController();
    final jornadasCtrl = TextEditingController(text: '1');
    String? error;
    bool saving = false;

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
                    controller: jornadasCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jornadas cubiertas',
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
                  onPressed: saving
                      ? null
                      : () async {
                          final amount =
                              double.tryParse(amountCtrl.text.trim());
                          final jornadas =
                              int.tryParse(jornadasCtrl.text.trim());

                          if (amount == null || amount <= 0 ||
                              jornadas == null || jornadas <= 0) {
                            setInnerState(() {
                              error = 'Ingresa monto y jornadas válidos';
                            });
                            return;
                          }

                          final confirmed = await showConfirmDialog(
                            context: context,
                            title: 'Registrar pago',
                            message:
                                'Este registro limpiará la deuda actual. ¿Deseas continuar?',
                          );
                          if (confirmed != true) return;
                          if (saving) return;
                          setInnerState(() {
                            saving = true;
                          });

                          _service.recordPayment(
                            amount: amount,
                            jornadasCovered: jornadas,
                            recordedBy: 'delivery',
                          );
                          Navigator.of(ctx).pop(true);
                        },
                  icon: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: saving ? const Text('Guardando...') : const Text('Guardar'),
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
                            Text(
                              'Jornadas cubiertas: ${payment.jornadasCovered}',
                            ),
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
