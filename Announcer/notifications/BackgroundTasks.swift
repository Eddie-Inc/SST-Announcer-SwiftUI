//
//  BackgroundTasks.swift
//  Announcer
//
//  Created by Ayaan Jain on 20/3/23.
//

import Foundation
import UIKit //hehe
import SwiftUI
import BackgroundTasks
import PostManager
import UserNotifications



@available(iOS 16.0, *)
@main
struct MyApp: App {
    
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
                await scheduleAppRefresh()
            }
    }
    
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            // Your implementation here
            return true
        }
    }
    
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }
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
    
    
    
    @Environment(\.scenePhase) private var phase
    
    
    
    
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.KaiTayAyaanJain.SSTAnnouncer")
        request.earliestBeginDate = .now.addingTimeInterval(24 * 3600)
        
        try? BGTaskScheduler.shared.submit(request)
        
        
        do {
            // code to run
            let fetchedItems = try PostManager.fetchValues(range: 0..<10)
            let diff = PostManager.addPostsToStorage(newItems: fetchedItems)
            if diff > 0 {
                // send local notif
                let content = UNMutableNotificationContent()
                for item in fetchedItems {
                    content.title = item.title
                // your content code here
                }
                content.title = PostManager.Post.title
                content.subtitle = PostManager.Post.content4
                content.sound = UNNotificationSound.default
                
                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }
        } catch {
            print("An error occured: \(error)")
        }
    }
    
}
