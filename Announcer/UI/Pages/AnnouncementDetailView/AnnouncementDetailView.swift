//
//  AnnouncementDetailView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI

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

    var body: some View {
        List {
            VStack(alignment: .leading) {
                title
                categories
                postAndReminder
            }

            if !post.getLinks().isEmpty {
                links
            }

            bodyText
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
                        safariViewURL = post.getBlogURL()
                        isLoadingSafariView = false
                        showShareLink = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    post.pinned.toggle()
                } label: {
                    Image(systemName: post.pinned ? "pin.fill" : "pin")
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
                ActivityView(text: safariViewURL.description)
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
                     content: "<p>\(placeholderTextLong)<p>",
                     date: .now,
                     pinned: true,
                     read: false,
                     categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ],
                     userCategories: [
                        .init("placeholder")
                     ])), posts: .constant([]))
        }
    }
}
