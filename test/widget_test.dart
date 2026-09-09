import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

import 'package:connectcall/main.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (WidgetTester tester) async {
    GetStorage.init();

    await tester.pumpWidget(const ConnectCallApp(initialThemeMode: ThemeMode.light));

    expect(find.text('ConnectCall'), findsOneWidget);
    expect(find.text('Connect with anyone, anywhere.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    tester.takeException();
  });
}
