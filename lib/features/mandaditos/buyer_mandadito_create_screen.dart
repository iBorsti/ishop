import 'package:flutter/material.dart';

import '../../core/auth/widgets/role_guard.dart';
import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import 'mandadito_service.dart';

class BuyerMandaditoCreateScreen extends StatefulWidget {
  const BuyerMandaditoCreateScreen({super.key});

  @override
  State<BuyerMandaditoCreateScreen> createState() =>
      _BuyerMandaditoCreateScreenState();
}

class _BuyerMandaditoCreateScreenState
    extends State<BuyerMandaditoCreateScreen> {
  final _originCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  bool _urgent = false;
  bool _submitting = false;

  @override
  void dispose() {
    _originCtrl.dispose();
    _descriptionCtrl.dispose();
    _destinationCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final origin = _originCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final destination = _destinationCtrl.text.trim();
    if (origin.isEmpty || description.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa origen, destino y descripción')),
      );
      return;
    }
    final budgetText = _budgetCtrl.text.trim();
    final budget = budgetText.isEmpty ? null : double.tryParse(budgetText);
    final ownerId = AuthController.instance.user?.id ?? '';

    setState(() => _submitting = true);
    await MandaditoService.createMandadito(
      origin: origin,
      description: description,
      destination: destination,
      urgent: _urgent,
      budget: budget,
      createdBy: ownerId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mandadito publicado')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requiredRole: UserRole.buyer,
      allowIfUnauthenticated: true,
      child: Scaffold(
        appBar: AppBar(title: const Text('Mandaditos')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Publica un mandadito',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _originCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Lugar de origen',
                    hintText: 'Ej. Mercado municipal',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Qué necesitas',
                    hintText: 'Ej. Media libra de queso + C\$30 de frijoles',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destinationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Destino',
                    hintText: 'Ej. Barrio Las Flores, casa verde',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Urgencia:'),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Normal'),
                      selected: !_urgent,
                      onSelected: (v) => setState(() => _urgent = false),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Urgente'),
                      selected: _urgent,
                      onSelected: (v) => setState(() => _urgent = true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Presupuesto (opcional)',
                    prefixText: 'C\$ ',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Publicar mandadito'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
