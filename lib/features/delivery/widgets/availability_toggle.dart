import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/availability_provider.dart';

class AvailabilityToggle extends ConsumerStatefulWidget {
  const AvailabilityToggle({super.key});

  @override
  ConsumerState<AvailabilityToggle> createState() => _AvailabilityToggleState();
}

class _AvailabilityToggleState extends ConsumerState<AvailabilityToggle> {
  bool loading = true;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Simular obtención de estado: después de 5s mostrar estado real
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      // Tras la carga inicial, marcamos disponible en el provider
      ref.read(availabilityProvider.notifier).setAvailable(true);
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(availabilityProvider);

    final bgColor = loading
        ? Colors.grey.withAlpha(30)
        : (available
              ? AppColors.successGreen.withAlpha(30)
              : Colors.grey.withAlpha(30));

    return FocusableActionDetector(
      focusNode: _focusNode,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<Intent>(
          onInvoke: (intent) {
            if (!loading) {
              ref.read(availabilityProvider.notifier).toggle();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ref.read(availabilityProvider)
                        ? 'Ahora disponible'
                        : 'Ahora no disponible',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
            return null;
          },
        ),
      },
      child: Semantics(
        label: 'Estado de disponibilidad',
        value: loading
            ? 'Cargando'
            : (available ? 'Disponible' : 'No disponible'),
        toggled: available,
        enabled: !loading,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: _focusNode.hasFocus
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: loading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Icon(
                        available ? Icons.check_circle : Icons.pause_circle,
                        key: ValueKey(available),
                        color: available ? AppColors.successGreen : Colors.grey,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loading
                      ? 'Cargando estado...'
                      : (available
                            ? 'Disponible para pedidos'
                            : 'No disponible'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Tooltip(
                message: loading
                    ? 'Espere a que cargue el estado'
                    : (available
                          ? 'Desactivar disponibilidad'
                          : 'Activar disponibilidad'),
                child: Switch(
                  value: available,
                  activeThumbColor: AppColors.successGreen,
                  onChanged: loading
                      ? null
                      : (value) {
                          ref
                              .read(availabilityProvider.notifier)
                              .setAvailable(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Ahora disponible'
                                    : 'Ahora no disponible',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
