import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zippy/core/common_widgets/home_screen_header.dart';
import 'package:zippy/core/shared_providers/location/application/get_current_location_state.dart';
import 'package:zippy/core/shared_providers/location/provider/get_current_location_provider.dart';
import 'package:zippy/core/theme/zyppi_theme.dart';

/// Stays in the "detecting" state instead of calling Geolocator.
class _DetectingLocation extends GetCurrentLocationProvider {
  _DetectingLocation(super.ref);

  @override
  Future<void> getCurrentLocation() async {
    state = GetCurrentLocationState.initial();
  }
}

void main() {
  testWidgets('location loader stays a small inline spinner', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentLocation.overrideWith((ref) => _DetectingLocation(ref)),
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
}
