import UIKit
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    override init() {
        super.init()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) {
                (granted, error) in 
                if let error = error {
                    print(error)
                } else if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()//If they allow notifications 
                    }
                }
            }
    }

    // send notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping () -> Void) {
        logContents(of: notification)
        completionHandler([.banner, .sound]) //send notification with banner and with sound
    }

    // Send in background
    func userNotificationCenter(_center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        logContents(of: response.notification)
        completionHandler()
    }

    func logContents(of notification: UNNotification) {
        print(notification.request.content.userInfo) //get content of notification
    }
}
