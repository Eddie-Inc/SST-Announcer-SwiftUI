//
//  PostPreviewView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import SwiftUI
import RichText

struct PostPreviewView: View {
    @Binding
    var post: Post

    @Binding
    var posts: [Post]

    var body: some View {
        if #available(iOS 16.0, *) {
            VStack(alignment: .leading) {
                title
                textPreview
                postAndReminder
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                swipeActions
            }
            .contextMenu {
                Button("Pin") {
                }
                Button("Mark as Read") {
                }
            } preview: {
                nextView
            }
        } else {
            VStack(alignment: .leading) {
                title
                textPreview
                postAndReminder
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                swipeActions
            }
            .contextMenu {
                Button("Pin") {
                }
                Button("Mark as Read") {
                }
            }
        }
    }

    var title: some View {
        HStack {
            if post.pinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(.accentColor)
                    .font(.footnote)
            }
            Text(post.title)
                .fontWeight(.semibold)
                .lineLimit(2)

            Spacer()
            NavigationLink {
                nextView
                    .onAppear {
                        post.read = true
                    }
            } label: {
                EmptyView()
            }
            .frame(width: 0, height: 0)
        }
        .padding(.bottom, 0.5)
    }

    var textPreview: some View {
        ZStack {
            Text(post.content.stripHTML().trimmingCharacters(in: .whitespacesAndNewlines))
                .opacity(post.read ? 0.3 : 0.7)
                .lineLimit(3)
                .padding(.bottom, 0.5)
        }
    }

    var postAndReminder: some View {
        // post and reminder
        HStack {
            TimeAndReminder(post: post)
                .opacity(post.read ? 0.5 : 0.6)

            CategoryScrollView(post: $post)
                .font(.footnote)
        }
        .font(.footnote)
    }

    @ViewBuilder
    var swipeActions: some View {
        Button {
            withAnimation {
                post.read.toggle()
            }
        } label: {
            Label(post.read ? "Unread" : "Read",
                  systemImage: post.read ? "book.closed" : "book.fill")
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

    var nextView: some View {
        AnnouncementDetailView(post: $post, posts: $posts)
            .onChange(of: post) { changedPost in
                PostManager.savePost(post: changedPost)
            }
    }
}

struct PostPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                PostPreviewView(post: .constant(
                    Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                         content: placeholderTextLong,
                         date: .now,
                         pinned: true,
                         read: false,
                         categories: [
                            "short",
                            "secondary 3",
                            "you wanted more?"
                         ])), posts: .constant([]))
            }
            .navigationTitle("Preview")
            .listStyle(.inset)
        }
    }
}
