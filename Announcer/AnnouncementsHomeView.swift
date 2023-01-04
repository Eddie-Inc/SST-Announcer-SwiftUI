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

    @State
    var searchString: String = ""

    @State
    var searchScope: String = ""

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
        if #available(iOS 16.0, *) {
            content
                .searchScopes($searchScope) {
                    Text("All Posts")
                    Text("Saved Posts")
                }
                .sheet(isPresented: $showFilterView) {
                    EditFilterView(posts: posts, searchString: $searchString)
                        .presentationDetents(Set([.medium, .large]))
                }
        } else {
            content
                .sheet(isPresented: $showFilterView) {
                    EditFilterView(posts: posts, searchString: $searchString)
                }
        }
    }

    var content: some View {
        List {
            ForEach($posts, id: \.title) { $post in
                PostPreviewView(post: $post)
            }
        }
        .listStyle(.inset)
        .searchable(text: $searchString)
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
    }
}

struct AnnouncementsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementsHomeView()
        }
    }
}
