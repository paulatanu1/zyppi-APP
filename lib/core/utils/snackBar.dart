import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zippy/core/constants/colors.dart';
import 'package:zippy/core/infrastructure/dioExceptions.dart';

Future<void> showSuccessToast({String? message}) async {
  await Fluttertoast.showToast(
      msg: message ?? '',
      backgroundColor: AppColors.black,
      toastLength: Toast.LENGTH_LONG,
      textColor: AppColors.white);
}

Future<void> showDioError(dynamic e) async {
  final errorResponse = DioExceptions.fromDioError(dioException: e);

  await Fluttertoast.showToast(
      msg: errorResponse.toString(),
      backgroundColor: AppColors.black,
      toastLength: Toast.LENGTH_LONG,
      textColor: AppColors.white);
}

Future<void> showConnectionInterrupted() async {
  await Fluttertoast.showToast(
      msg: 'Connection Was Interrupted',
      backgroundColor: AppColors.black,
      toastLength: Toast.LENGTH_LONG,
      textColor: AppColors.white);
}
