import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/loginModel.dart';

part 'loginState.freezed.dart';

@freezed
class LoginState with _$LoginState {
  factory LoginState(
      {bool? loading, UserResponse? userResponse}) = _LoginState;

  const LoginState._();
}
