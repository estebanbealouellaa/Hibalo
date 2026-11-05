// The shared V6 widgets (lib/widgets/v6): buttons and the text field.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6.dart';

Widget _app(Widget child) => MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(20), child: child))),
    );

Material _materialOf(WidgetTester tester, Finder button) =>
    tester.widget<Material>(find.descendant(of: button, matching: find.byType(Material)).first);

void main() {
  group('V6Button', () {
    testWidgets('every style: 52 high (48 for text styles), plum text on coral and citrus', (tester) async {
      for (final style in V6ButtonStyle.values) {
        await tester.pumpWidget(_app(V6Button(label: 'Go', style: style, onPressed: () {})));
        final text = style == V6ButtonStyle.text || style == V6ButtonStyle.dangerText;
        expect(tester.getSize(find.byType(V6Button)).height, text ? 48 : 52, reason: '$style');
        final label = tester.widget<Text>(find.text('Go'));
        final expected = switch (style) {
          V6ButtonStyle.primary || V6ButtonStyle.strong => V6Colors.onPrimary,
          V6ButtonStyle.secondary => V6Colors.onPrimaryContainer,
          V6ButtonStyle.text => V6Colors.primary,
          V6ButtonStyle.coral => V6Colors.primaryStrong,
          V6ButtonStyle.citrus => V6Colors.onCitrus,
          V6ButtonStyle.dangerText => V6Colors.error,
        };
        expect(label.style!.color, expected, reason: '$style');
      }
    });

    testWidgets('tapping calls onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(V6Button(label: 'Go', onPressed: () => taps++)));
      await tester.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('disabled: State/Disabled fill, Text/Disabled label, not tappable', (tester) async {
      await tester.pumpWidget(_app(const V6Button(label: 'Go', onPressed: null)));
      expect(_materialOf(tester, find.byType(V6Button)).color, V6Colors.stateDisabled);
      expect(tester.widget<Text>(find.text('Go')).style!.color, V6Colors.textDisabled);
    });

    testWidgets('loading: spinner, primary fill kept, taps ignored', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_app(V6Button(label: 'Signing in…', loading: true, onPressed: () => taps++)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(_materialOf(tester, find.byType(V6Button)).color, V6Colors.primary);
      await tester.tap(find.text('Signing in…'));
      expect(taps, 0);
    });

    testWidgets('without expand it hugs its label, also inside a stretched column', (tester) async {
      await tester.pumpWidget(_app(Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: V6Button(label: 'Go', style: V6ButtonStyle.text, onPressed: () {})),
          Align(alignment: Alignment.centerLeft, child: V6TextLink(label: 'Sign in', onTap: () {})),
        ],
      )));
      expect(tester.getSize(find.byType(V6Button)).width, lessThan(200));
      expect(tester.getSize(find.byType(V6TextLink)).width, lessThan(200));
      expect(tester.getTopLeft(find.byType(V6Button)).dx, 20);
    });

    testWidgets('expand makes it full width', (tester) async {
      await tester.pumpWidget(_app(V6Button(label: 'Go', expand: true, onPressed: () {})));
      expect(tester.getSize(find.byType(V6Button)).width, 800 - 40);
    });
  });

  group('V6TextField', () {
    OutlineInputBorder? border(WidgetTester tester) {
      final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
      final d = decorator.decoration;
      if (d.errorText != null) return (decorator.isFocused ? d.focusedErrorBorder : d.errorBorder) as OutlineInputBorder?;
      if (!d.enabled) return d.disabledBorder as OutlineInputBorder?;
      return (decorator.isFocused ? d.focusedBorder : d.enabledBorder) as OutlineInputBorder?;
    }

    testWidgets('default: label above, hint, 1 px neutral border, 52 high', (tester) async {
      await tester.pumpWidget(_app(const V6TextField(label: 'Email', hint: 'Enter email')));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Enter email'), findsOneWidget);
      expect(border(tester)!.borderSide.color, V6Colors.borderNeutral);
      expect(border(tester)!.borderSide.width, 1);
      expect(tester.getSize(find.byType(TextFormField)).height, greaterThanOrEqualTo(52));
    });

    testWidgets('auth field label is uppercase violet', (tester) async {
      await tester.pumpWidget(_app(const V6TextField(label: 'Email', fieldLabel: true)));
      expect(find.text('EMAIL'), findsOneWidget);
      expect(tester.widget<Text>(find.text('EMAIL')).style!.color, V6Colors.primary);
    });

    testWidgets('focused: 2 px primary border', (tester) async {
      await tester.pumpWidget(_app(const V6TextField(label: 'Email')));
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(border(tester)!.borderSide.color, V6Colors.primary);
      expect(border(tester)!.borderSide.width, 2);
    });

    testWidgets('error: 2 px error border and the message', (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(_app(Form(
        key: key,
        child: V6TextField(label: 'Email', validator: (v) => 'Enter your email'),
      )));
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Enter your email'), findsOneWidget);
      expect(border(tester)!.borderSide.color, V6Colors.error);
      expect(border(tester)!.borderSide.width, 2);
    });

    testWidgets('disabled: State/Disabled fill, no typing', (tester) async {
      await tester.pumpWidget(_app(const V6TextField(label: 'Email', enabled: false)));
      final d = tester.widget<InputDecorator>(find.byType(InputDecorator)).decoration;
      expect(d.fillColor, V6Colors.stateDisabled);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });

    testWidgets('password: hidden, the eye shows and hides it', (tester) async {
      await tester.pumpWidget(_app(const V6TextField(label: 'Password', obscure: true)));
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    });
  });
}
