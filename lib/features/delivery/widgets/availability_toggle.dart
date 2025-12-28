import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final available = ref.watch(availabilityProvider);

    final bgColor = loading
        ? Colors.grey.withAlpha(30)
        : (available ? AppColors.successGreen.withAlpha(30) : Colors.grey.withAlpha(30));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Icon(
              available ? Icons.check_circle : Icons.pause_circle,
              color: available ? AppColors.successGreen : Colors.grey,
              size: 32,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loading ? 'Cargando estado...' : (available ? 'Disponible para pedidos' : 'No disponible'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: available,
            activeThumbColor: AppColors.successGreen,
            onChanged: loading
                ? null
                : (value) {
                    ref.read(availabilityProvider.notifier).setAvailable(value);
                  },
          ),
        ],
      ),
    );
  }
}
