import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.freezed.dart';
part 'address.g.dart';

@freezed
abstract class Address with _$Address {
  factory Address({
    required String id,
    required String label, // "Home", "Work", "Other"
    required String line1,
    required String area,
    required String city,
    required String state,
    required String postalCode,
    String? landmark,
    required double lat,
    required double lng,
    @Default(false) bool isDefault,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}
