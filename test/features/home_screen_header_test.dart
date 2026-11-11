import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/data/provider/profile_provider.dart';
import 'package:zippy/core/domain/profile.dart';
import 'package:zippy/core/shared_providers/location/application/get_current_location_state.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Stays in the "detecting" state instead of calling Geolocator.
class _DetectingLocation extends GetCurrentLocationProvider {
  _DetectingLocation(super.ref);

  @override
  Future<void> getCurrentLocation({bool requestPermission = false}) async {
    state = GetCurrentLocationState.initial();
  }
}

void main() {
  testWidgets('location loader stays a small inline spinner', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentLocation.overrideWith((ref) => _DetectingLocation(ref)),
          // Profile still loading.
          profileProvider.overrideWith((ref) => Completer<Profile>().future),
        ],
        child: MaterialApp(
          theme: ZyppiTheme.light,
          home: const Scaffold(
            body: SizedBox(width: 390, child: HomeScreenHeader()),
          ),
        ),
      ),
    );

    final spinner = tester.getSize(find.byType(CircularProgressIndicator));
    expect(spinner.width, lessThanOrEqualTo(12));
    expect(spinner.height, lessThanOrEqualTo(12));
    expect(find.text('detectingLocation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  Future<void> pumpHeader(WidgetTester tester, Profile profile) =>
      tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentLocation.overrideWith((ref) => _DetectingLocation(ref)),
            profileProvider.overrideWith((ref) async => profile),
          ],
          child: MaterialApp(
            theme: ZyppiTheme.light,
            home: const Scaffold(
              body: SizedBox(width: 390, child: HomeScreenHeader()),
            ),
          ),
        ),
      );

  testWidgets('avatar shows the signed-in user\'s initial', (tester) async {
    await pumpHeader(tester, Profile(id: 'u1', fullName: 'atanu paul'));
    await tester.pump();

    expect(find.text('A'), findsOneWidget);
    expect(find.text('zyppiExpress'), findsOneWidget);
    expect(find.text('etaHeadline'), findsOneWidget);
    // Search moved to HomeScreen's pinned header.
    expect(find.text('homeSearchHint'), findsNothing);
    expect(find.byIcon(Icons.mic_none_rounded), findsNothing);
  });

  testWidgets('guests get the person icon, not an initial', (tester) async {
    await pumpHeader(
      tester,
      Profile(id: 'g1', fullName: 'Guest', isGuest: true),
    );
    await tester.pump();

    expect(find.text('G'), findsNothing);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
  });
}
