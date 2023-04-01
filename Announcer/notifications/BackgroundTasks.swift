//
//  BackgroundTasks.swift
//  Announcer
//
//  Created by Ayaan Jain on 20/3/23.
//

import Foundation
import SwiftUI
import BackgroundTasks
import PostManager
import UserNotifications


class BackgroundTasksStruct: NSObject {
    
    
    
    let notificationDelegate = NotificationDelegate()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    static func main() async {
        //just needed to make this work
    }
    
    @available(iOS 16.0, *)
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: phase) { newPhase in
            //...
        }
        .backgroundTask(.appRefresh("myapprefresh")) {
            await self.scheduleAppRefresh()
        }
    }
    
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
extension Scene {
    func refreshIfPossible(
        identifier: String,
        action: @Sendable @escaping () async -> Void
    ) -> some Scene {
        if #available(iOS 16.0, *) {
            return self.backgroundTask(.appRefresh(identifier), action: action)
        } else {
            // Fallback on earlier versions
            return self
        }
    }
}

extension YourApp {
    class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        // Your implementation of UNUserNotificationCenterDelegate methods here

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
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.KaiTayAyaanJain.SSTAnnouncer")
        request.earliestBeginDate = .now.addingTimeInterval(24 * 3600)

        try? BGTaskScheduler.shared.submit(request)


        do {
            let fetchedItems = try PostManager.fetchValues(range: 0..<10)
            let diff = PostManager.addPostsToStorage(newItems: fetchedItems)
            if diff > 0 {
                let content = UNMutableNotificationContent()
                content.title = "New Posts Available"
                content.body = "\(diff) new posts are available"
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
        catch {
            print("An error occured: \(error)")
        }
    }
    func handle(task: BGAppRefreshTask) {
        // Handle the app refresh task here
        task.expirationHandler = {
            // Handle task expiration if needed
        }
        
        // Create a new instance of the task to start it again after it finishes
        let newTask = BGAppRefreshTaskRequest(identifier: "com.KaiTayAyaanJain.SSTAnnouncer")
        newTask.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(newTask)
        } catch {
            print("Unable to reschedule app refresh: \(error)")
        }
    }
}




class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
        
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions:
                         [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
            
            // Request authorization for local and remote notifications
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                if let error = error {
                    print("Error requesting notification authorization: \(error)")
                } else {
                    print("Notification authorization granted: \(granted)")
                }
            }
            application.registerForRemoteNotifications()
            application.registerForRemoteNotifications()
            
            // Schedule app refresh task
            if #available(iOS 13.0, *) {
                let request = BGAppRefreshTaskRequest(identifier: "com.KaiTayAyaanJain.SSTAnnouncer")
                request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Schedule the task for 15 minutes from now
                do {
                    try BGTaskScheduler.shared.submit(request)
                    print("App refresh task scheduled successfully")
                } catch {
                    print("Unable to schedule app refresh task: \(error)")
                }
            }
            
            return true
        }
        
        // Handle local notifications when app is in the foreground
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    didReceive response: UNNotificationResponse,
                                    withCompletionHandler completionHandler: @escaping () -> Void) {
            print("Local notification received: \(response.notification.request.content.title)")
            completionHandler()
        }
    }
    

