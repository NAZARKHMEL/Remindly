import Flutter
import UIKit
import UserNotifications

@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("Ошибка при запросе разрешений: \(error.localizedDescription)")
        } else if granted {
            print("Уведомления разрешены")
        } else {
            print("Уведомления не разрешены")
        }
    }
    
    DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
