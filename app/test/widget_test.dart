import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jugaadi/screens/auth/phone_auth_screen.dart';

void main() {
  testWidgets('phone auth screen shows a phone field and send button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PhoneAuthScreen()));

    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
