import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:outlook/main.dart';

void main() {
  testWidgets('shows the login screen first', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(const MailApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in to your email'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });
}
