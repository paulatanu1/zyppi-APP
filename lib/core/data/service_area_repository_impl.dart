import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zippy/core/config/env.dart';
import 'package:zippy/core/data/mock_service_area_repository_impl.dart';
import 'package:zippy/core/data/service_area_repository.dart';
import 'package:zippy/core/data/firebase_service_area_repository_impl.dart';

final serviceAreaRepositoryProvider = Provider<ServiceAreaRepository>(
  (ref) => Env.isMockDataSource
      ? MockServiceAreaRepository()
      : FirebaseServiceAreaRepository(FirebaseFirestore.instance),
);
