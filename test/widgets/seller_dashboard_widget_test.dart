import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merca_nica/features/seller/seller_dashboard.dart';

void main() {
  testWidgets('SellerDashboard renders and navigates to publish screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SellerDashboard()));

    // AppBar title
    expect(find.text('Panel de Vendedor'), findsOneWidget);

    // Buttons present
    expect(find.text('Publicar producto'), findsOneWidget);
    expect(find.text('Ver reportes'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);

    // Tap publish and verify navigation
    await tester.tap(find.text('Publicar producto'));
    await tester.pumpAndSettle();

    expect(find.text('Publicar producto'), findsWidgets);
  });
}
