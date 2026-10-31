import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // PhonePe's SDK resumes the payment flow when the PhonePe app redirects
  // back via our custom URL scheme (see Info.plist's CFBundleURLTypes).
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    NotificationCenter.default.post(
      name: NSNotification.Name("ApplicationOpenURLNotification"),
      object: nil,
      userInfo: ["url": url, "options": options]
    )
    return true
  }
}
