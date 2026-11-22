import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:docvault/models/company_item.dart';
import 'package:docvault/screens/company_selection_screen.dart';

void main() {
  final dummyCompany = CompanyItem(
    id: 'c1',
    name: 'Empresa Teste',
    description: 'Desc',
    segment: 'Tecnologia',
    icon: Icons.business,
    accentColor: Colors.blue,
    adminName: 'Admin',
    documents: [],
  );

  testWidgets('CompanySelectionScreen renders on mobile (360x800) with buttons below logo', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: CompanySelectionScreen(
          companies: [dummyCompany],
          onSelectCompany: (_) {},
          isDarkMode: false,
          onToggleDarkMode: (_) {},
        ),
      ),
    );

    // Verify elements exist
    expect(find.text('DocVault'), findsOneWidget);
    expect(find.text('PORTAL PÚBLICO'), findsOneWidget);
    expect(find.text('Tema Escuro'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);

    // On mobile, the theme button should be vertically below the DocVault logo
    final logoTopLeft = tester.getTopLeft(find.text('DocVault'));
    final buttonTopLeft = tester.getTopLeft(find.text('Tema Escuro'));
    expect(buttonTopLeft.dy, greaterThan(logoTopLeft.dy));
  });

  testWidgets('CompanySelectionScreen renders on ultra-narrow mobile (320x640) without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: CompanySelectionScreen(
          companies: [dummyCompany],
          onSelectCompany: (_) {},
          isDarkMode: true,
          onToggleDarkMode: (_) {},
        ),
      ),
    );

    expect(find.text('DocVault'), findsOneWidget);
    expect(find.text('PORTAL PÚBLICO'), findsOneWidget);
    expect(find.text('Tema Claro'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
  });

  testWidgets('CompanySelectionScreen renders on desktop (1200x800) with buttons on the right side', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: CompanySelectionScreen(
          companies: [dummyCompany],
          onSelectCompany: (_) {},
          isDarkMode: false,
          onToggleDarkMode: (_) {},
        ),
      ),
    );

    expect(find.text('DocVault'), findsOneWidget);
    expect(find.text('PORTAL PÚBLICO'), findsOneWidget);
    expect(find.text('Tema Escuro'), findsOneWidget);

    // On desktop, the theme button and DocVault text should be horizontally aligned
    final logoCenter = tester.getCenter(find.text('DocVault'));
    final buttonCenter = tester.getCenter(find.text('Tema Escuro'));
    expect((buttonCenter.dy - logoCenter.dy).abs(), lessThan(10));
    expect(buttonCenter.dx, greaterThan(logoCenter.dx));
  });
}
