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

@main
struct MyApp: App {

    @Environment(\.scenePhase) private var phase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: phase) { newPhase in
            if newPhase == .background {
                scheduleAppRefresh()
            }
        }
        .refreshIfPossible(identifier: "com.kaitayayaanjain.announcer.background") {
            scheduleAppRefresh()
        }
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
                let latestPost = PostManager.getCachePosts(range: 0..<diff)
                for post in latestPost {
                    content.title = post.title
                    content.subtitle = post.content
                    content.sound = UNNotificationSound.default

                    // show this notification five seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
            }
        } catch {
            print("An error occured: \(error)")
        }
    }
}
