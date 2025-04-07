import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/profile/view/update_page.dart';

void main() {
  testWidgets('Should render Update Page correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: UpdatePage()));

    // Verify initial UI
    expect(find.text('First Name'), findsOneWidget);

    // Simulate user input
    await tester.enterText(find.byType(TextField).first, 'John');
    expect(find.text('John'), findsOneWidget);
  });
}
