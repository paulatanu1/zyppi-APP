import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/legal/application/legal_providers.dart';
import 'package:zippy/core/legal/data/legal_repository_impl.dart';
import 'package:zippy/core/legal/domain/legal_doc.dart';
import 'package:zippy/core/legal/domain/legal_repository.dart';
import 'package:zippy/core/legal/presentation/legal_gate.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

class _Legal implements LegalRepository {
  _Legal(this.live);

  List<PendingLegalDoc> live;
  final accepted = <List<PendingLegalDoc>>[];
  bool fail = false;
  bool offline = false;

  @override
  Future<List<PendingLegalDoc>> pending() async {
    if (offline) throw Exception('offline');
    return live;
  }

  @override
  Future<LegalDocText?> fetchText(String type, String languageCode) async =>
      null;

  @override
  Future<void> accept(List<PendingLegalDoc> docs) async {
    if (fail) throw Exception('TERMS_CHANGED');
    accepted.add(docs);
    live = const [];
  }
}

const _terms = PendingLegalDoc(
  type: LegalTypes.customerTerms,
  version: 2,
  title: 'Terms',
  sha256: 'h',
);

void main() {
  late _Legal legal;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester, {bool agreedAtLogin = false}) async {
    container = ProviderContainer(
      overrides: [legalRepositoryProvider.overrideWithValue(legal)],
    );
    addTearDown(container.dispose);
    if (agreedAtLogin) {
      container.read(legalAgreedAtLoginProvider.notifier).set(true);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ZyppiTheme.light,
          home: const LegalGate(child: Text('APP')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the app when everything is accepted', (tester) async {
    legal = _Legal(const []);
    await pump(tester);
    expect(find.text('APP'), findsOneWidget);
  });

  testWidgets('does not lock the customer out when the check fails', (
    tester,
  ) async {
    legal = _Legal(const [_terms])..offline = true;
    await pump(tester);
    expect(find.text('APP'), findsOneWidget);
  });

  testWidgets('asks for a new version and needs the box ticked', (
    tester,
  ) async {
    legal = _Legal(const [_terms]);
    await pump(tester);
    expect(find.text('APP'), findsNothing);
    expect(find.text('legalUpdatedTitle'), findsOneWidget);

    await tester.tap(find.text('legalAgreeContinue'));
    await tester.pump();
    expect(legal.accepted, isEmpty);
    expect(find.text('legalAgreeRequired'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('legalAgreeContinue'));
    await tester.pumpAndSettle();
    expect(legal.accepted.single.single.version, 2);
    expect(find.text('APP'), findsOneWidget);
  });

  testWidgets('says so when saving fails, and keeps asking', (tester) async {
    legal = _Legal(const [_terms])..fail = true;
    await pump(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('legalAgreeContinue'));
    await tester.pumpAndSettle();
    expect(find.text('legalAcceptFailed'), findsOneWidget);
    expect(find.text('APP'), findsNothing);
  });

  testWidgets('records what was ticked on the login screen without asking', (
    tester,
  ) async {
    legal = _Legal(const [_terms]);
    await pump(tester, agreedAtLogin: true);
    expect(legal.accepted, hasLength(1));
    expect(find.text('APP'), findsOneWidget);
    expect(find.text('legalUpdatedTitle'), findsNothing);
    expect(container.read(legalAgreedAtLoginProvider), isFalse);
  });
}
