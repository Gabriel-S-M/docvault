import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:docvault/main.dart';
import 'package:docvault/widgets/document_list_tile.dart';

// 1x1 transparent PNG bytes
final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }
}

class MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  Stream<List<int>> asBroadcastStream({
    void Function(StreamSubscription<List<int>> subscription)? onListen,
    void Function(StreamSubscription<List<int>> subscription)? onCancel,
  }) => Stream.value(kTransparentImage);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(kTransparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

void main() {
  setUpAll(() async {
    HttpOverrides.global = TestHttpOverrides();
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('Initial screen renders CompanySelectionScreen with both companies', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Title and Selection Screen elements
    expect(find.text('DocVault'), findsOneWidget);
    expect(find.text('PORTAL PÚBLICO'), findsOneWidget);
    expect(find.text('Qual empresa você deseja consultar?'), findsOneWidget);

    // Verify both companies are listed
    expect(find.text('AlphaTech Soluções Digitais'), findsOneWidget);
    expect(find.text('LogiPrime Logística & Operações'), findsOneWidget);
    expect(find.text('4 documentos'), findsNWidgets(2));
  });

  testWidgets('Selecting a company opens DocVault with that company public documents without login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap on AlphaTech Soluções Digitais
    await tester.tap(find.text('AlphaTech Soluções Digitais'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that we are on DocVaultScreen showing AlphaTech docs
    expect(find.text('4 docs'), findsOneWidget);
    expect(find.text('AlphaTech Soluções Digitais'), findsOneWidget);

    // AlphaTech documents should be visible
    expect(find.text('Relatório Anual 2024'), findsOneWidget);
    expect(find.text('Proposta Comercial — Q1 2025'), findsOneWidget);
    expect(find.text('Política de Privacidade v3.1'), findsOneWidget);
    expect(find.text('Plano de Marketing Digital 2025'), findsOneWidget);

    // LogiPrime documents should NOT be visible here
    expect(find.text('Manual de Procedimentos Internos'), findsNothing);
  });

  testWidgets('Filtering by search query updates documents list in active company', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Select AlphaTech
    await tester.tap(find.text('AlphaTech Soluções Digitais'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Enter search text
    await tester.enterText(find.byType(TextField).first, 'Privacidade');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Only 'Política de Privacidade v3.1' should be visible
    expect(find.text('Política de Privacidade v3.1'), findsOneWidget);
    expect(find.text('Relatório Anual 2024'), findsNothing);
  });

  testWidgets('Trocar Empresa inside OptionsPanel returns to selection screen and allows entering LogiPrime', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Select AlphaTech
    await tester.tap(find.text('AlphaTech Soluções Digitais'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Relatório Anual 2024'), findsOneWidget);

    // Open Opções menu
    await tester.tap(find.text('Opções'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap "Trocar Empresa"
    await tester.tap(find.text('Trocar Empresa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Back to Selection Screen
    expect(find.text('Qual empresa você deseja consultar?'), findsOneWidget);

    // Now select LogiPrime
    await tester.tap(find.text('LogiPrime Logística & Operações'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify LogiPrime documents are loaded
    expect(find.text('Manual de Procedimentos Internos'), findsOneWidget);
    expect(find.text('Contrato de Prestação de Serviços'), findsOneWidget);
    expect(find.text('Ata da Reunião — Fevereiro 2025'), findsOneWidget);
    expect(find.text('Manual de Identidade Visual'), findsOneWidget);

    // AlphaTech docs should NOT be present
    expect(find.text('Relatório Anual 2024'), findsNothing);
  });

  testWidgets('Admin login for active company, Edit Modal, and Admin OptionsPanel with logout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Select AlphaTech
    await tester.tap(find.text('AlphaTech Soluções Digitais'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Opções on Home
    await tester.tap(find.text('Opções'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Submit admin login (prefilled with company admin credentials)
    expect(find.text('Entrar no Painel Admin'), findsOneWidget);
    await tester.tap(find.text('Entrar no Painel Admin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Admin Screen is now active
    expect(find.text('ADMIN'), findsOneWidget);
    expect(find.text('Gerenciar documentos'), findsOneWidget);

    // Tap edit pencil on first Admin Card
    final editPencil = find.byIcon(Icons.edit_outlined).first;
    await tester.tap(editPencil);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap "Editar documento" in popover
    expect(find.text('Editar documento'), findsWidgets);
    await tester.tap(find.text('Editar documento').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Edit Modal appears with Automatic PDF Metadata
    expect(find.text('ADMINISTRAÇÃO'), findsOneWidget);
    expect(find.text('METADADOS DO PDF'), findsOneWidget);
    expect(find.text('Automático'), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);

    // Tap Cancelar to close modal
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Open Opções menu from Admin header
    await tester.tap(find.text('Opções'));
    await tester.pumpAndSettle();

    // Verify admin info is displayed in OptionsPanel
    expect(find.text('Admin AlphaTech'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);

    // Logout from OptionsPanel
    await tester.tap(find.text('Sair da conta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Back to user home view of that company
    expect(find.text('Todos os documentos'), findsOneWidget);
  });

  testWidgets('List mode in Admin expands tile to reveal Edit and Delete buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MainApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Select AlphaTech
    await tester.tap(find.text('AlphaTech Soluções Digitais'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Log into Admin
    await tester.tap(find.text('Opções'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Entrar no Painel Admin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Switch to List Mode
    await tester.tap(find.text('Opções'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Lista'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify DocumentListTile is rendered
    expect(find.byType(DocumentListTile), findsWidgets);

    // Tap on the first tile
    await tester.tap(find.byType(DocumentListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify inline Edit and Delete buttons appear
    expect(find.text('Editar'), findsWidgets);
    expect(find.text('Excluir'), findsWidgets);

    // Tap on the tile again to collapse
    await tester.tap(find.byType(DocumentListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Editar'), findsNothing);
    expect(find.text('Excluir'), findsNothing);
  });
}
