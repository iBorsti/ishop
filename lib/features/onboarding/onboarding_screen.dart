import 'package:flutter/material.dart';

import '../../core/config/app_env.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import 'onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingRole role;
  final String userId;
  final VoidCallback onFinished;

  const OnboardingScreen({
    super.key,
    required this.role,
    required this.userId,
    required this.onFinished,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;
  late final List<_OnboardingPageData> _pages;
  int _index = 0;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _pages = _pagesFor(widget.role);
  }

  List<_OnboardingPageData> _pagesFor(OnboardingRole role) {
    switch (role) {
      case OnboardingRole.delivery:
        return [
          _OnboardingPageData(
            title: 'Controla tus jornadas sin enredos',
            body:
                'Esta app solo lleva el registro de los días que trabajas y lo que debes.\nNo te quita trabajo ni te bloquea.',
            cta: 'Continuar',
            accent: AppGradients.delivery.colors.last,
          ),
          _OnboardingPageData(
            title: 'Pagas al final del día',
            highlight: 'C\$100 por jornada',
            body:
                'Si un día no pagas, no pasa nada.\nSe acumula y la app te lo recuerda.',
            cta: 'Entendido',
            accent: AppGradients.delivery.colors.first,
          ),
          _OnboardingPageData(
            title: 'Tú tienes el control',
            bullets: const [
              'No hay cobros automáticos',
              'No hay castigos',
              'Tú decides cuándo pagar',
            ],
            cta: 'Empezar',
            accent: AppGradients.delivery.colors.last,
          ),
        ];
      case OnboardingRole.fleet:
        return [
          _OnboardingPageData(
            title: 'Controla tu flota sin enredos',
            body: 'Puedes ver todas tus motos y sus cuotas diarias.',
            cta: 'Continuar',
            accent: AppGradients.fleet.colors.last,
          ),
          _OnboardingPageData(
            title: 'Pagas al final del día',
            highlight: 'C\$50 por moto / día',
            body:
                'Si un día no pagas, se acumula por moto.\nLa app solo te lo recuerda.',
            cta: 'Entendido',
            accent: AppGradients.fleet.colors.first,
          ),
          _OnboardingPageData(
            title: 'Tú tienes el control',
            bullets: const [
              'No hay cobros automáticos',
              'No hay castigos',
              'La deuda se acumula por moto',
            ],
            cta: 'Empezar',
            accent: AppGradients.fleet.colors.last,
          ),
        ];
      case OnboardingRole.buyer:
        return [
          _OnboardingPageData(
            title: 'Compra o pide lo que necesites',
            body:
                'Puedes comprar productos publicados\no pedir encargos personalizados.',
            cta: 'Ver productos',
            accent: AppGradients.buyer.colors.last,
          ),
        ];
    }
  }

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    await OnboardingService.markOnboardingCompleted(
      widget.userId,
      widget.role,
    );
    if (!mounted) return;
    widget.onFinished();
  }

  void _nextOrFinish() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  _Indicator(count: _pages.length, index: _index),
                  if (AppConfig.isDemo)
                    TextButton(
                      onPressed: _complete,
                      child: const Text('Saltar'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completing ? null : _nextOrFinish,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: page.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(page.cta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final int count;
  final int index;

  const _Indicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 18 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (data.highlight != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              data.highlight!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        if (data.body != null)
          Text(
            data.body!,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        if (data.bullets != null) ...[
          const SizedBox(height: 12),
          ...data.bullets!.map(
            (b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b, style: const TextStyle(fontSize: 16))),
                ],
              ),
            ),
          ),
        ],
        const Spacer(),
      ],
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String? body;
  final String? highlight;
  final List<String>? bullets;
  final String cta;
  final Color accent;

  const _OnboardingPageData({
    required this.title,
    this.body,
    this.highlight,
    this.bullets,
    required this.cta,
    required this.accent,
  });
}
