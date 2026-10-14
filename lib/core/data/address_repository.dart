import 'package:zippy/core/domain/address.dart';

abstract class AddressRepository {
  Future<List<Address>> fetchAddresses();
}
