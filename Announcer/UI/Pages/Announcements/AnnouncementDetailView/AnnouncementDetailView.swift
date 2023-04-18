//
//  AnnouncementDetailView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI
import PostManager
import OrderedCollections
import LinkPresentation

let noZeroAndPoint: CharacterSet = .init(["0", "."])

struct AnnouncementDetailView: View {

    @Binding
    var post: Post

    @Binding
    var posts: [Post]

    @State
    var showEditCategoryView: Bool = false

    @State
    var showEditReminderDateView: Bool = false

    @AppStorage("textPresentationMode")
    var textPresentationMode: TextPresentationMode = .rendered

    @AppStorage("fontSize")
    var fontSize: Double = 17

    // this is used for both the Safari view loading and share sheet
    @State
    var safariViewURL: URL?

    @State
    var showShareLink: Bool = false

    @State
    var showSafariView: Bool = false

    @State
    var isLoadingSafariView: Bool = false

    @State
    var metadatas: OrderedDictionary<URL, LPLinkMetadata> = [:]

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            VStack {
                title
                categories
                postAndReminder
            }
            .swipeActions(edge: .leading,
                          allowsFullSwipe: true) {
                Button {
                    post.read = false
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Unread", systemImage: "book.closed")
                }
                .tint(.accentColor)

                Button {
                    withAnimation {
                        post.pinned.toggle()
                    }
                } label: {
                    Label(post.pinned ? "Unpin" : "Pin",
                          systemImage: post.pinned ? "pin.slash.fill" : "pin.fill")
                }
                .tint(.gray)
            }

            bodyText

            if !post.getLinks().isEmpty {
                links
            }
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .overlay(alignment: .bottom) {
            sizeView
                .opacity(resizePopupOpacity)
        }
        .overlay(alignment: .center) {
            if isLoadingSafariView {
                Text("Loading...")
                    .padding(10)
                    .background {
                        Rectangle()
                            .foregroundColor(.init(UIColor.systemGroupedBackground))
                            .cornerRadius(5)
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isLoadingSafariView = true
                    loadQueue.async {
                        defer { isLoadingSafariView = false }
                        guard let url = post.blogUrl else { return }
                        safariViewURL = URL(string: url)
                        showShareLink = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        post.pinned.toggle()
                    } label: {
                        Label(post.pinned ? "Unpin" : "Pin",
                              systemImage: post.pinned ? "pin.fill" : "pin")
                    }
                    Button {
                        showEditCategoryView.toggle()
                    } label: {
                        Label("User Categories",
                              systemImage: (post.userCategories?.isEmpty ?? true) ? "tag" : "tag.fill")
                    }
                    if SettingsManager.shared.enableReminders {
                        Button {
                            showEditReminderDateView.toggle()
                        } label: {
                            Label("Reminder Date",
                                  systemImage: post.reminderDate == nil ? "calendar.badge.plus" : "calendar.badge.nil")
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showEditCategoryView) {
            if #available(iOS 16.0, *) {
                addNewCategory
                    .presentationDetents(Set([.large, .medium]))
            } else {
                // Fallback on earlier versions
                addNewCategory
            }
        }
        .sheet(isPresented: $showEditReminderDateView) {
            if #available(iOS 16.0, *) {
                editReminderDate
                    .presentationDetents(Set([.large, .medium]))
            } else {
                // Fallback on earlier versions
                editReminderDate
            }
        }
        .sheet(isPresented: $showSafariView) {
            if let safariViewURL {
                SafariView(url: safariViewURL)
            } else {
                Text("URL not found")
            }
        }
        .sheet(isPresented: $showShareLink) {
            if let safariViewURL {
                ActivityView(content: safariViewURL)
            } else {
                Text("URL not found")
            }
        }
    }

    @State var originalFontSize: Double = 0
    @State var isResizing: Bool = false
    // usually synced with isResizing, but lingers a while after isResizing turns false
    @State var resizePopupOpacity: Double = 0
}

struct AnnouncementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementDetailView(post: .constant(
                Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                     authors: ["Somebody"],
                     content: placeholderTextLong,
                     date: .now,
                     blogURL: "http://www.google.com",
                     categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ])), posts: .constant([]))
        }
    }
}
