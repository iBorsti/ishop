import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/auth/models/app_user.dart';
import '../../core/auth/state/auth_controller.dart';
import '../../core/auth/widgets/role_guard.dart';
import '../../core/theme/app_theme.dart';
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
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  bool _saving = false;
  static const _kDraftKeyPrefix = 'seller_product_draft_';

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _titleCtrl.text = widget.initial!.title ?? '';
      _descriptionCtrl.text = widget.initial!.description;
      final p = widget.initial!.price;
      if (p != null) _priceCtrl.text = p.toStringAsFixed(0);
      _imageUrlCtrl.text = widget.initial!.imageUrl ?? '';
    } else {
      _restoreDraft();
    }
    _imageUrlCtrl.addListener(() => setState(() {}));
    // Usaremos WillPopScope en el build para manejar el guardado del borrador
    // y evitar el uso de las APIs de pop registradas en la ruta.
  }

  @override
  void dispose() {
    // No es necesario remover callbacks de ruta — WillPopScope gestiona el pop.
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<bool> _handleWillPop() async {
    await _saveDraft();
    return true;
  }

  String get _draftKey => '$_kDraftKeyPrefix${widget.initial?.id ?? "new"}';

  Future<void> _restoreDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_draftKey);
      if (raw == null) return;
      final map = json.decode(raw) as Map<String, dynamic>;
      _titleCtrl.text = map['title'] as String? ?? '';
      _descriptionCtrl.text = map['description'] as String? ?? '';
      _priceCtrl.text = (map['price'] as Object?)?.toString() ?? '';
      _imageUrlCtrl.text = map['imageUrl'] as String? ?? '';
      setState(() {});
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'title': _titleCtrl.text,
      'description': _descriptionCtrl.text,
      'price': _priceCtrl.text,
      'imageUrl': _imageUrlCtrl.text,
    };
    await prefs.setString(_draftKey, json.encode(map));
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
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
    final title = _titleCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final price = double.parse(_priceCtrl.text.trim());
    final imageUrl = _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim();

    setState(() => _saving = true);
    try {
      if (widget.initial == null) {
        await SellerPostService.createProduct(
          userId: userId,
          title: title.isEmpty ? null : title,
          description: description,
          price: price,
          imageUrl: imageUrl,
          sellerName: user?.name ?? 'Vendedor',
        );
      } else {
        await SellerPostService.updatePost(
          userId: userId,
          postId: widget.initial!.id,
          title: title.isEmpty ? null : title,
          description: description,
          price: price,
          imageUrl: imageUrl,
          sellerName: user?.name,
          sellerId: user?.id,
        );
      }
      await _clearDraft();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return RoleGuard(
      requiredRole: UserRole.seller,
      child: WillPopScope(
        onWillPop: _handleWillPop,
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
                  children: <Widget>[
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Ingresa un título' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Ej. Combo de pollo frito',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Ingresa una descripción';
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
                        if (value == null || value <= 0) return 'Ingresa un precio válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(labelText: 'URL imagen (opcional)'),
                    ),
                    const SizedBox(height: 12),
                    if (_imageUrlCtrl.text.isNotEmpty)
                      Center(
                        child: SizedBox(
                          height: 140,
                          child: Image.network(
                            _imageUrlCtrl.text,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64),
                          ),
                        ),
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
                        style: isEdit ? AppButtonStyles.success : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
