//
//
//  Created by Ayaan Jain on 3/10/2023
//
//



import SwiftUI
import Foundation
import Amplify

class DeviceTokenManager {
    private init() {}
    static let shared  =DeviceTokenManager

    var deviceToken: String?
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken //get device token to send it push notifications
            .map { String(format: "%02.2hhx", $0) }
            .joined()

        DeviceTokenManager.shared.deviceToken = token
    }
}



@main 
struct push_notifications_handler: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //Connect App Delegate to rest of app

    @State var notificationsService = NotificationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: notificationService.requestPermission)
        }
    }
}