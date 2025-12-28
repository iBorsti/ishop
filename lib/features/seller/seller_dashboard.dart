import 'package:flutter/material.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/simple_line_chart.dart';
import '../../core/theme/app_colors.dart';
import 'publish_product_screen.dart';
import 'seller_reports_screen.dart';
import 'seller_history_screen.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Fake data
    final todaySales = '24';
    final monthIncome = 'C\$ 12,450';
    final productsSold = '136';
    final chartData = [5.0, 8.0, 6.0, 10.0, 9.0, 12.0, 11.0, 15.0, 13.0];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Panel de Vendedor'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(title: 'Ventas hoy', value: todaySales, icon: Icons.local_mall),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(title: 'Ingresos mes', value: monthIncome, icon: Icons.attach_money),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StatCard(title: 'Productos vendidos', value: productsSold, icon: Icons.inventory_2),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ventas (últimos 9 días)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Expanded(
                              child: SimpleLineChart(data: chartData, lineColor: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PublishProductScreen()));
                          },
                          icon: const Icon(Icons.post_add),
                          label: const Text('Publicar producto'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerReportsScreen()));
                          },
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('Ver reportes'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryBlue),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerHistoryScreen()));
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('Historial'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
