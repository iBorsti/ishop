import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/models/seller_profile.dart';
import '../../../core/auth/state/auth_controller.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  late SellerProfile _profile;
  final _formKey = GlobalKey<FormState>();
  final _displayCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _catsCtrl = TextEditingController();
  bool _pickup = true;
  bool _delivery = true;

  @override
  void initState() {
    super.initState();
    final existing = AuthController.instance.sellerProfile ?? SellerProfile(type: SellerType.individual, displayName: AuthController.instance.user?.name);
    _profile = existing;
    _displayCtrl.text = _profile.displayName ?? '';
    _businessCtrl.text = _profile.businessName ?? '';
    _addressCtrl.text = _profile.address ?? '';
    _hoursCtrl.text = _profile.openingHours ?? '';
    _logoCtrl.text = _profile.logoUrl ?? '';
    _taxCtrl.text = _profile.taxId ?? '';
    _catsCtrl.text = _profile.categories.join(',');
    _pickup = _profile.isPickupAvailable;
    _delivery = _profile.isDeliveryAvailable;
  }

  @override
  void dispose() {
    _displayCtrl.dispose();
    _businessCtrl.dispose();
    _addressCtrl.dispose();
    _hoursCtrl.dispose();
    _logoCtrl.dispose();
    _taxCtrl.dispose();
    _catsCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cats = _catsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final newProfile = SellerProfile(
      type: _profile.type,
      displayName: _displayCtrl.text.trim(),
      businessName: _businessCtrl.text.trim().isEmpty ? null : _businessCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      openingHours: _hoursCtrl.text.trim().isEmpty ? null : _hoursCtrl.text.trim(),
      logoUrl: _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim(),
      taxId: _taxCtrl.text.trim().isEmpty ? null : _taxCtrl.text.trim(),
      isPickupAvailable: _pickup,
      isDeliveryAvailable: _delivery,
      categories: cats,
      verified: _profile.verified,
    );
    await AuthController.instance.updateSellerProfile(newProfile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil guardado')));
    Navigator.pop(context, true);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (file == null) return;
    // For prototype we store local file path in logoUrl. In production upload to server and store URL.
    _logoCtrl.text = file.path;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil vendedor')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Tipo:')),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Negocio'),
                      selected: _profile.type == SellerType.business,
                      onSelected: (v) => setState(() => _profile = _profile.copyWith(type: SellerType.business)),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Independiente'),
                      selected: _profile.type == SellerType.individual,
                      onSelected: (v) => setState(() => _profile = _profile.copyWith(type: SellerType.individual)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _displayCtrl, decoration: const InputDecoration(labelText: 'Nombre mostrado')),
                const SizedBox(height: 12),
                if (_profile.type == SellerType.business) ...[
                  TextFormField(controller: _businessCtrl, decoration: const InputDecoration(labelText: 'Nombre comercial')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _taxCtrl, decoration: const InputDecoration(labelText: 'Tax ID (opcional)')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _hoursCtrl, decoration: const InputDecoration(labelText: 'Horario (ej. Lun-Vie 8:00-17:00)')),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _logoCtrl, decoration: const InputDecoration(labelText: 'URL logo (opcional)'))),
                    const SizedBox(width: 8),
                    IconButton(onPressed: _pickLogo, icon: const Icon(Icons.photo_library)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _catsCtrl, decoration: const InputDecoration(labelText: 'Categorías (separadas por coma)')),
                const SizedBox(height: 12),
                SwitchListTile(value: _pickup, onChanged: (v) => setState(() => _pickup = v), title: const Text('Recogida disponible')),
                SwitchListTile(value: _delivery, onChanged: (v) => setState(() => _delivery = v), title: const Text('Entrega a domicilio')),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Guardar perfil'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
