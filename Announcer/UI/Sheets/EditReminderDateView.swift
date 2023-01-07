//
//  EditReminderDateView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/1/23.
//

import SwiftUI

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
                        post.reminderDate = newValue
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
                                                  pinned: true,
                                                  read: false,
                                                  categories: [
                                                      "short",
                                                      "secondary 3",
                                                      "you wanted more?"
                                                  ],
                                                  userCategories: [
                                                      .init("Placeholder")
                                                  ])),
                             showEditReminderDateView: .constant(true))
    }
}
