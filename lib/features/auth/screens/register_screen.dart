import 'package:flutter/material.dart';
import '../../../core/auth/state/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../role_selector_screen.dart';
import '../../../core/auth/models/app_user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  UserRole? _selectedRole;
  final _ctrl = AuthController.instance;
  bool _loading = false;

  Future<void> _pickRole() async {
    final res = await Navigator.push<UserRole?>(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectorScreen()),
    );
    if (res != null) setState(() => _selectedRole = res);
  }

  Future<void> _create() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un rol primero')),
      );
      return;
    }
    setState(() => _loading = true);
    await _ctrl.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _selectedRole!,
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickRole,
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
    );
  }
}
