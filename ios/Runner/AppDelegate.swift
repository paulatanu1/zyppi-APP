import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyAENU5SJ0T0vCXnrCHfpe2RtSaHBnW7gkw")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
