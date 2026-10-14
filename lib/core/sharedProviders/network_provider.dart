import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/infrastructure/network_api_services.dart';

final networkProvider = Provider((ref) => NetworkApiServices());
