import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merca_nica/features/buyer/buyer_home_screen.dart';

void main() {
  testWidgets('BuyerHomeScreen shows appbar and feed actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BuyerHomeScreen()));

    // AppBar title
    expect(find.text('Inicio'), findsOneWidget);

    // Buyer feed should include product card buttons
    expect(find.text('Comprar'), findsWidgets);
    expect(find.text('Compartir'), findsWidgets);

    // Icons in appbar
    expect(find.byIcon(Icons.search), findsOneWidget);
    // Avatar icon repeats in the feed, expect at least some
    expect(find.byIcon(Icons.person), findsWidgets);
  });
}
