//
//  AppDelegate.swift
//  Announcer
//
//  Created by Kai Quan Tay on 24/1/23.
//

import UIKit
import UserNotifications
import PostManager

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Log.info("Finished launching with options \(launchOptions)")
        registerForPushNotifications()
        return true
    }

    private func registerForPushNotifications() {
        let current = UNUserNotificationCenter.current()
        current.delegate = self
        current.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if let error {
                Log.info("Request auth had error: \(error)")
            }

            Log.info("Requested permission. Granted? \(granted)")

            // Check to see if permission is granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                Log.info("Attempting registration")
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Log.info("Token: \(token)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.info("Failed to register remote notifications: \(error.localizedDescription)")
    }
}
