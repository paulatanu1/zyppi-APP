# PayU CheckoutPro (payu_checkoutpro_flutter). Its SDK is reflection- and
# WebView-heavy, so keep it whole, and ignore optional integrations it only
# calls when present (Google Pay in-app SDK, phone-number hint API).
-keep class com.payu.** { *; }
-keep class com.payubiz.** { *; }
-dontwarn com.payu.**
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-dontwarn com.google.android.gms.auth.api.credentials.**
