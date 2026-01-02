import 'package:flutter/material.dart';

import '../../../core/auth/state/auth_controller.dart';
import '../../../core/auth/models/seller_profile.dart';
import '../services/seller_metrics_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'seller_profile_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );

  int _ventas = 0;
  double _ingresos = 0.0;
  double _conversion = 0.0;
  List<int> _daily = [];
  // Detalle para business
  int _customers = 0;
  List<Map<String, Object>> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  void _loadMetrics() {
    // Mock implementation: replace with real data calls
    final days = _range.end.difference(_range.start).inDays + 1;
    _daily = List.generate(days, (i) => (5 + i * 2) % 15 + 1);
    _ventas = _daily.fold(0, (a, b) => a + b);
    _ingresos = _ventas * 120.5; // ejemplo
    _conversion = (_ventas / (100 + days * 5)) * 100;
    // mock extra
    _customers = (_ventas * 3) ~/ 4;
    _topProducts = [
      {'name': 'Producto A', 'count': 34},
      {'name': 'Producto B', 'count': 22},
      {'name': 'Producto C', 'count': 12},
    ];
    setState(() {});
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _range.start,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _range = DateTimeRange(start: picked, end: _range.end);
      _loadMetrics();
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _range.end,
      firstDate: _range.start,
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _range = DateTimeRange(start: _range.start, end: picked);
      _loadMetrics();
    });
  }

  Widget _kpiCard(String label, String value, {Color? color}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color ?? Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = AuthController.instance.sellerProfile;
    final isBusiness = profile?.type == SellerType.business;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de control'),
        actions: [
          if (profile != null && profile.logoUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(profile.logoUrl!),
                onBackgroundImageError: (_, __) {},
              ),
            ),
          IconButton(
            tooltip: 'Exportar CSV',
            icon: const Icon(Icons.download),
            onPressed: () async {
              final uid = AuthController.instance.user?.id;
              if (uid == null) return;
              final messenger = ScaffoldMessenger.of(context);
              final csv = await SellerMetricsService.exportCsv(uid, _range.start, _range.end);
              await Clipboard.setData(ClipboardData(text: csv));
              if (!mounted) return;
              messenger.showSnackBar(const SnackBar(content: Text('CSV copiado al portapapeles')));
            },
          ),
          IconButton(
            tooltip: 'Editar perfil vendedor',
            icon: const Icon(Icons.person),
            onPressed: () async {
              final res = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const SellerProfileScreen()),
              );
              if (res == true) setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _pickStart,
                    icon: const Icon(Icons.calendar_today),
                    label: Text('${_range.start.day}/${_range.start.month}/${_range.start.year}'),
                  ),
                  const SizedBox(width: 8),
                  Text('—'),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _pickEnd,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('${_range.end.day}/${_range.end.month}/${_range.end.year}'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _loadMetrics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _kpiCard('Ventas', '$_ventas', color: Colors.teal),
                  const SizedBox(width: 8),
                  _kpiCard('Ingresos', 'C\$ ${_ingresos.toStringAsFixed(2)}', color: Colors.green),
                  const SizedBox(width: 8),
                  _kpiCard('Conversión', '${_conversion.toStringAsFixed(1)}%', color: Colors.indigo),
                ],
              ),
              const SizedBox(height: 12),
              if (isBusiness) ...[
                Row(
                  children: [
                    _kpiCard('Clientes (mes)', '$_customers', color: Colors.orange),
                    const SizedBox(width: 8),
                    _kpiCard('Top producto', '${_topProducts.isNotEmpty ? _topProducts.first['name'] : '-'}', color: Colors.purple),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ventas por día', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Expanded(
                          child: FutureBuilder<Map<DateTime, double>>(
                            future: AuthController.instance.user?.id == null
                                ? Future.value({})
                                : SellerMetricsService.dailyTotals(AuthController.instance.user!.id, _range.start, _range.end),
                            builder: (context, snap) {
                              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                              final data = snap.data ?? {};
                              final entries = data.entries.toList();
                              return BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (entries.map((e) => e.value).fold<double>(0, (a, b) => a > b ? a : b)) + 10,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (i, meta) {
                                          final idx = i.toInt();
                                          if (idx < 0 || idx >= entries.length) return const SizedBox();
                                          final dt = entries[idx].key;
                                          return Text('${dt.day}/${dt.month}');
                                        },
                                        reservedSize: 30,
                                      ),
                                    ),
                                  ),
                                  gridData: FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(entries.length, (i) {
                                    final v = entries[i].value;
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [BarChartRodData(toY: v, color: Theme.of(context).colorScheme.primary)],
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isBusiness) ...[
                          const Divider(),
                          Text('Productos más vendidos', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          FutureBuilder<List<Map<String, Object>>>(
                            future: AuthController.instance.user?.id == null
                                ? Future.value([])
                                : SellerMetricsService.topProducts(AuthController.instance.user!.id, _range.start, _range.end),
                            builder: (ctx, snap) {
                              final list = snap.data ?? [];
                              if (list.isEmpty) return const Text('No hay datos');
                              return Column(
                                children: list.map((p) => ListTile(dense: true, title: Text(p['name'] as String), trailing: Text('${p['count']}'))).toList(),
                              );
                            },
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Text('Resumen simplificado para vendedor independiente', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
