//
//  AnnouncementsHomeView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI

let placeholderTextShort = "Lorem ipsum dolor sit amet"
let placeholderTextLong = """
Dear Students,

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt \
ut labore et dolore magna aliqua. Turpis egestas pretium aenean pharetra. Orci eu lobortis.

elementum nibh tellus molestie. Vulputate dignissim suspendisse in est. Vel pharetra vel \
turpis nunc. Malesuada nunc vel risus commodo. Nisi vitae suscipit tellus mauris.

Posuere orbi leo urna molestie at elementum eu. Urna duis convallis convallis tellus. Urna molestie \
at elementum eu. Nunc sed blandit libero volutpat.
"""

struct AnnouncementsHomeView: View {
    @State
    var posts: [Post] = []

    @State
    var showFilterView: Bool = false

    init() {
        PostManager.getPosts(range: 0..<10) { posts, error in
            if let error {
                Log.info("Error: \(error.localizedDescription)")
                return
            }
            if let posts {
                _posts = State(initialValue: posts)
            }
        }
    }

    var body: some View {
        List {
            ForEach($posts, id: \.title) { $post in
                NavigationLink {
                    AnnouncementDetailView(post: $post)
                        .onChange(of: post) { changedPost in
                            PostManager.savePost(post: changedPost)
                        }
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            if post.pinned {
                                Image(systemName: "pin.fill")
                                    .foregroundColor(.accentColor)
                                    .font(.footnote)
                                    .padding(.trailing, -4)
                            }
                            Text(post.title)
                                .lineLimit(2)
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
        .listStyle(.inset)
        .searchable(text: .constant(""))
        .navigationTitle("Announcements")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showFilterView.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showFilterView) {
            if #available(iOS 16.0, *) {
                EditFilterView(posts: posts)
                    .presentationDetents(Set([.medium, .large]))
            } else {
                EditFilterView(posts: posts)
            }
        }
    }
}

struct AnnouncementsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementsHomeView()
        }
    }
}
