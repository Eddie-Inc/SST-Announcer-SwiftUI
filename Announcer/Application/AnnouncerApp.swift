
import Foundation
import SwiftUI
import BackgroundTasks
import PostManager
import OneSignalFramework

@main
struct YourApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Application did launch")

        // Remove this method to stop OneSignal Debugging
               OneSignal.Debug.setLogLevel(.LL_VERBOSE)
                
               // OneSignal initialization
               OneSignal.initialize("856bbc0e-4c79-4d7e-bc8f-1b63ad85ee66", withLaunchOptions: launchOptions)

               // requestPermission will show the native iOS notification permission prompt.
               // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
               OneSignal.Notifications.requestPermission({ accepted in
                 print("User accepted notifications: \(accepted)")
               }, fallbackToSettings: true)

        return true
    }
}



