import 'package:flutter/material.dart';
import '../../../core/auth/state/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../role_selector_screen.dart';
import '../../../core/auth/models/app_user.dart';
import '../../../core/auth/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole? _selectedRole;
  final _ctrl = AuthController.instance;
  bool _loading = false;

  void _fillDemo() {
    setState(() {
      _nameCtrl.text = 'Demo User';
      _emailCtrl.text = 'demo+buyer@demo.app';
      _passCtrl.text = 'demo1234';
      _selectedRole = UserRole.buyer;
    });
  }

  Future<void> _pickRole() async {
    final res = await Navigator.push<UserRole?>(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectorScreen()),
    );
    if (res != null) setState(() => _selectedRole = res);
  }

  Future<void> _create() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un rol primero')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _ctrl.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _selectedRole!,
      );
    } catch (e) {
      final msg = e is AuthException ? e.message : 'No se pudo registrar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresa tu nombre' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu email';
                  if (!v.contains('@')) return 'Email no válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                  if (v.length < 4) return 'Mínimo 4 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.flash_on),
                    tooltip: 'Autocompletar demo',
                    onPressed: _loading ? null : _fillDemo,
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : _pickRole,
                      child: Text(
                        _selectedRole == null
                            ? 'Seleccionar rol'
                            : _selectedRole.toString().split('.').last,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      onPressed: _loading ? null : _create,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Crear cuenta'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
