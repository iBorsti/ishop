import 'package:flutter/material.dart';

import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/auth/widgets/role_guard.dart';
import '../../core/theme/app_colors.dart';
import 'services/seller_post_service.dart';
import 'models/seller_post.dart';

class SellerCreateProductScreen extends StatefulWidget {
  final SellerPost? initial;

  const SellerCreateProductScreen({super.key, this.initial});

  @override
  State<SellerCreateProductScreen> createState() =>
      _SellerCreateProductScreenState();
}

class _SellerCreateProductScreenState extends State<SellerCreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _descriptionCtrl.text = widget.initial!.description;
      final p = widget.initial!.price;
      if (p != null) _priceCtrl.text = p.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    final user = AuthController.instance.user;
    final userId = user?.id ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión como vendedor')),
      );
      return;
    }
    final description = _descriptionCtrl.text.trim();
    final price = double.parse(_priceCtrl.text.trim());

    setState(() => _saving = true);
    if (widget.initial == null) {
      await SellerPostService.createProduct(
        userId: userId,
        description: description,
        price: price,
        sellerName: user?.name ?? 'Vendedor',
      );
    } else {
      await SellerPostService.updatePost(
        userId: userId,
        postId: widget.initial!.id,
        description: description,
        price: price,
        sellerName: user?.name,
        sellerId: user?.id,
      );
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return RoleGuard(
      requiredRole: UserRole.seller,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'Editar producto' : 'Publicar producto'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ej. Combo de pollo frito',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa una descripción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      prefixText: 'C\$ ',
                    ),
                    validator: (v) {
                      final txt = v?.trim() ?? '';
                      final value = double.tryParse(txt);
                      if (value == null || value <= 0) {
                        return 'Ingresa un precio válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? 'Guardar cambios' : 'Publicar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isEdit ? AppColors.successGreen : AppColors.turquoise,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
