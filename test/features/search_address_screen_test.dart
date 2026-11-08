import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/data/provider/addresses_provider.dart';
import 'package:zippy/core/domain/address.dart';
import 'package:zippy/core/domain/service_area.dart';
import 'package:zippy/core/shared_providers/location/application/get_current_location_state.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';
import 'package:zippy/features/search_address/presentation/search_address_screen.dart';

import '../helpers/localized_app.dart';

/// A resolved, serviceable location instead of Geolocator.
class _Resolved extends GetCurrentLocationProvider {
  _Resolved(super.ref, {required bool serviceable}) {
    state = GetCurrentLocationState.initial().copyWith(
      isDetecting: false,
      address: 'Ranchi Road, Near Saheb Bandh, Purulia, West Bengal 723101',
      line1: 'Ranchi Road',
      serviceabilityChecked: true,
      serviceArea: serviceable ? ServiceArea(id: 's1', name: 'Purulia') : null,
    );
  }

  @override
  Future<void> getCurrentLocation({bool requestPermission = false}) async {}
}

final _saved = Address(
  id: 'a1',
  label: 'Work',
  line1: 'Station Road',
  area: 'Purulia',
  city: 'Purulia',
  state: 'West Bengal',
  postalCode: '723101',
  lat: 0,
  lng: 0,
);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    bool addLocation = false,
    bool serviceable = true,
    ThemeData? theme,
    double textScale = 1,
  }) async {
    final c = ProviderContainer(
      overrides: [
        currentLocation.overrideWith(
          (ref) => _Resolved(ref, serviceable: serviceable),
        ),
        addressesProvider.overrideWith((ref) async => [_saved]),
      ],
    );
    addTearDown(c.dispose);
    await pumpLocalizedApp(
      tester,
      container: c,
      home: SearchAddressScreen(addLocation: addLocation),
      theme: theme,
      textScale: textScale,
    );
  }

  testWidgets('serviceable: address, note, Confirm enabled, saved list', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Ranchi Road'), findsWidgets);
    expect(find.text('We deliver here'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    await tester.scrollUntilVisible(
      find.text('Work'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('not serviceable: Confirm disabled', (tester) async {
    await pump(tester, serviceable: false);
    expect(find.text("We don't deliver here yet"), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('adding an address shows the label chips', (tester) async {
    await pump(tester, addLocation: true);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('no overflow (${dark ? 'dark' : 'light'}, $scale× text)', (
        tester,
      ) async {
        await pump(
          tester,
          addLocation: true,
          theme: dark ? ZyppiTheme.dark : ZyppiTheme.light,
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
