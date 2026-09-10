import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:transit_ci/app.dart';

void main() {
  testWidgets('Transit CI démarre sur l\'écran de bienvenue', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TransitCiApp()));
    await tester.pump();

    expect(find.text('Transit CI'), findsOneWidget);
  });
}
