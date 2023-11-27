//
//  PostPreviewView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import SwiftUI
import RichText
import PostManager

struct PostPreviewView: View {
    @Binding var post: Post

    @Binding var posts: [Post]

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
            TimeAndReminder(post: $post)
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
                // move the post to where its meant to be
                if post.pinned {
                    guard let currentIndex = posts.firstIndex(of: post),
                          let postInsertIndex = posts.firstIndex(where: { otherPost in
                              !otherPost.pinned || otherPost.date.timeIntervalSince1970 < post.date.timeIntervalSince1970
                          })
                    else { return }
                    posts.move(fromOffsets: .init(integer: currentIndex), toOffset: postInsertIndex)
                } else {
                    posts.sort { first, second in
                        if first.pinned == second.pinned {
                            // if both are pinned or both are unpinned, the later one goes first.
                            return first.date.timeIntervalSince1970 > second.date.timeIntervalSince1970
                        } else {
                            // if the first is pinned, first goes first. Else, second goes first.
                            return first.pinned
                        }
                    }
                }
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
                         blogURL: nil,
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
