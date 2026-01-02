import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de control')),
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
              const SizedBox(height: 20),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: _daily.map((v) {
                              final max = (_daily.isNotEmpty) ? _daily.reduce((a, b) => a > b ? a : b) : 1;
                              final h = (v / max) * 120.0;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(height: h, color: Theme.of(context).colorScheme.primary, width: double.infinity),
                                      const SizedBox(height: 6),
                                      Text(v.toString(), style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
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
