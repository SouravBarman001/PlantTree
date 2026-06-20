import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plant_tree/features/disease_detection/presentation/screens/home_screen.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('PlantTree'), findsOneWidget);
    expect(find.text('Take a picture'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Tools'), findsOneWidget);
  });
}
