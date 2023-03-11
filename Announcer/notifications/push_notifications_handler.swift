//
//
//  Created by Ayaan Jain on 3/10/2023
//
//



import SwiftUI
import Foundation
import Amplify
import AWSAPIPlugin
import AWSDataStorePlugin


class DeviceTokenManager {
    private init() {}
    static let shared = DeviceTokenManager.self

    var deviceToken: String?
}

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken //get device token to send it push notifications
            .map { String(format: "%02.2hhx", $0) }
            .joined()

        DeviceTokenManager.shared.deviceToken = token
    }
}



struct push_notifications_handler: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //Connect App Delegate to rest of app

    @State var notificationsService = NotificationService()
    
    init() {
        configureAmplify()  
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: NotificationService.requestPermission)
        }
    }
    
    func configureAmplify() {
        do {
            let models = AmplifyModels()
            try Amplify.add(plugin: AWSDataStorePlugin(modelRegistration: models))
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: models))
            
            try Amplify.configure()
            
            print("Configured amplify")
        } catch {
            print(error)
        }
    }
}
