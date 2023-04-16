//
//  EditReminderDateView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/1/23.
//

import SwiftUI
import PostManager

struct EditReminderDateView: View {
    @Binding
    var post: Post

    @Binding
    var showEditReminderDateView: Bool

    var body: some View {
        List {
            if let reminderDate = post.reminderDate {
                Section {
                    DatePicker("Edit Reminder Date", selection: .init(get: {
                        reminderDate
                    }, set: { newValue in
                        Log.info("YAY SOMETHING")
                        post.reminderDate = newValue

                        let content: UNMutableNotificationContent = .init()
                        content.title = "Reminder for \(post.title)"
                        content.body = "ITS TIMEEEEEEE"

                        let fireDate = Calendar.current.dateComponents(Set([.year, .month, .day, .hour, .minute]),
                                                                       from: .now.addingTimeInterval(20))
//                                                                       from: newValue)

                        Log.info("Fire date: \(fireDate)")

                        let trigger = UNCalendarNotificationTrigger(dateMatching: fireDate, repeats: false)

                        let notification: UNNotificationRequest = .init(identifier: post.id,
                                                                        content: content,
                                                                        trigger: trigger)

                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.add(notification) { error in
                            if let error {
                                Log.info("Notification for post \(post.title) had error: \(error)")
                            } else {
                                Log.info("Notification added!")
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                notificationCenter.getPendingNotificationRequests { requests in
                                    Log.info("Pending requests: \(requests.map({ $0.identifier }))")
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                                notificationCenter.getPendingNotificationRequests { requests in
                                    Log.info("Later pending requests: \(requests.map({ $0.identifier }))")
                                }
                            }
                        }
                    }))
                }
                Section {
                    Button("Remove Reminder Date") {
                    }
                }
            } else {
                Section {
                    DatePicker("Create Reminder Date", selection: .init(get: {
                        .now + (60*60*24) // now + 1 day
                    }, set: { newValue in
                        post.reminderDate = newValue
                    }))
                }
            }
        }
    }
}

struct EditReminderDateView_Previews: PreviewProvider {
    static var previews: some View {
        EditReminderDateView(post: .constant(Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                                                  content: placeholderTextLong,
                                                  date: .now,
                                                  blogURL: nil,
                                                  categories: [
                                                    "short",
                                                    "secondary 3",
                                                    "you wanted more?"
                                                  ])),
                             showEditReminderDateView: .constant(true))
    }
}
