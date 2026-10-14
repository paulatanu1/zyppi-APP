import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/login_model.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  factory LoginState({bool? loading, UserResponse? userResponse}) = _LoginState;

  const LoginState._();
}
