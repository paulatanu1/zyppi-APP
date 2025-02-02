import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/infrastructure/networkApiServices.dart';

final networkProvider = Provider((ref) => NetworkApiServices());