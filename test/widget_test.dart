import 'package:flutter_test/flutter_test.dart';
import 'package:maintsys_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaintSysApp());
  });
}
