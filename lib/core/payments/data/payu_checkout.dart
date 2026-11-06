import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:zippy/core/payments/domain/payment_order.dart';
import 'package:zippy/core/payments/domain/payment_repository.dart';
import 'package:zippy/core/theme/zyppi_colors.dart';

/// How a CheckoutPro session ended, as the SDK reported it. Only a hint:
/// the server's verify_payment decides whether the order is placed.
enum PayUCheckoutResult { success, failure, cancelled }

// PayU's own landing pages for SDK integrations; CheckoutPro intercepts
// them and reports the outcome through its callbacks.
const _successUrl = 'https://cbjs.payu.in/sdk/success';
const _failureUrl = 'https://cbjs.payu.in/sdk/failure';

/// Opens PayU CheckoutPro for [PaymentOrder] and completes once the SDK
/// reports an outcome. Hashes are signed by the server through
/// [PaymentRepository.signHash].
class PayUCheckout implements PayUCheckoutProProtocol {
  final PaymentRepository repository;

  late final PayUCheckoutProFlutter _sdk = PayUCheckoutProFlutter(this);
  Completer<PayUCheckoutResult>? _result;

  PayUCheckout(this.repository);

  Future<PayUCheckoutResult> open(PaymentOrder order) {
    final result = _result = Completer<PayUCheckoutResult>();
    unawaited(
      _sdk.openCheckoutScreen(
        payUPaymentParams: {
          PayUPaymentParamKey.key: order.key,
          PayUPaymentParamKey.transactionId: order.txnid,
          PayUPaymentParamKey.amount: order.amount,
          PayUPaymentParamKey.productInfo: order.productInfo,
          PayUPaymentParamKey.firstName: order.firstName,
          PayUPaymentParamKey.email: order.email,
          PayUPaymentParamKey.phone: order.phone,
          PayUPaymentParamKey.environment: order.environment,
          PayUPaymentParamKey.android_surl: _successUrl,
          PayUPaymentParamKey.android_furl: _failureUrl,
          PayUPaymentParamKey.ios_surl: _successUrl,
          PayUPaymentParamKey.ios_furl: _failureUrl,
          PayUPaymentParamKey.additionalParam: {
            PayUAdditionalParamKeys.udf1: '',
            PayUAdditionalParamKeys.udf2: '',
            PayUAdditionalParamKeys.udf3: '',
            PayUAdditionalParamKeys.udf4: '',
            PayUAdditionalParamKeys.udf5: '',
          },
        },
        payUCheckoutProConfig: {
          PayUCheckoutProConfigKeys.merchantName: 'Zyppi',
          PayUCheckoutProConfigKeys.primaryColor: _hex(ZColors.light.brand),
          PayUCheckoutProConfigKeys.secondaryColor: _hex(ZColors.light.onBrand),
          PayUCheckoutProConfigKeys.showExitConfirmationOnCheckoutScreen: true,
          PayUCheckoutProConfigKeys.showExitConfirmationOnPaymentScreen: true,
          PayUCheckoutProConfigKeys.enableSavedCard: false,
          PayUCheckoutProConfigKeys.merchantResponseTimeout: 30000,
        },
      ),
    );
    return result.future;
  }

  @override
  Future<void> generateHash(Map response) async {
    try {
      final hash = await repository.signHash(response);
      await _sdk.hashGenerated(hash: hash);
    } catch (_) {
      // An unsigned hash makes the SDK fail that step; report it as such.
      await _sdk.hashGenerated(hash: {response['hashName'] ?? '': ''});
    }
  }

  @override
  void onPaymentSuccess(dynamic response) =>
      _finish(PayUCheckoutResult.success, response);

  @override
  void onPaymentFailure(dynamic response) =>
      _finish(PayUCheckoutResult.failure, response);

  @override
  void onPaymentCancel(Map? response) =>
      _finish(PayUCheckoutResult.cancelled, response);

  /// Not terminal: CheckoutPro reports recoverable problems here (e.g. an
  /// optional offers hash the server declined) while its screen stays
  /// open, and still ends with success / failure / cancel.
  @override
  void onError(Map? response) => _log('onError', response);

  void _finish(PayUCheckoutResult result, dynamic response) {
    _log(result.name, response);
    final completer = _result;
    if (completer != null && !completer.isCompleted) completer.complete(result);
  }

  /// Callback name plus PayU's error code/message — never the payment
  /// response itself, which carries the payer's details.
  static void _log(String event, dynamic response) {
    final map = response is Map ? response : const {};
    debugPrint(
      'PayU $event errorCode=${map['errorCode']} errorMsg=${map['errorMsg']}',
    );
  }

  static String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
