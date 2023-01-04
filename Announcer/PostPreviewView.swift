//
//  PostPreviewView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import SwiftUI

struct PostPreviewView: View {
    @Binding
    var post: Post

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if post.pinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.accentColor)
                        .font(.footnote)
                }
                Text(post.title)
                    .lineLimit(2)

                Spacer()
                NavigationLink {
                    AnnouncementDetailView(post: $post)
                        .onChange(of: post) { changedPost in
                            PostManager.savePost(post: changedPost)
                        }
                } label: {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
            }
            .padding(.bottom, 0.5)

            // preview
            Text(post.content.replacingOccurrences(of: "\n\n", with: "\n"))
                .opacity(post.read ? 0.3 : 0.7)
                .lineLimit(3)
                .padding(.bottom, 0.5)

            // post and reminder
            HStack {
                Image(systemName: "timer")
                Text("03 Jan 2023")
                    .padding(.trailing, 10)
                Image(systemName: "alarm")
                Text("8h")
            }
            .font(.footnote)
            .opacity(post.read ? 0.5 : 0.6)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
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
    }
}

struct PostPreviewView_Previews: PreviewProvider {
    static var previews: some View {
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
                 ])))
    }
}
