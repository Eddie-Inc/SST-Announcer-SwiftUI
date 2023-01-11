//
//  AnnouncementsHomeView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI
import MarkdownUI

let loadQueue: DispatchQueue = .init(label: "sg.edu.sst.panziyue.Announcer.getPosts")

struct AnnouncementsHomeView: View {
    @State
    var posts: [Post] = []

    @State
    var showFilterView: Bool = false

    @State
    var searchString: String = ""

    @State
    var searchScope: String = ""

    @State
    var isLoading: Bool = false

    var body: some View {
        if #available(iOS 16.0, *) {
            content
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
            ForEach($posts.filter({
                searchString.isEmpty ||
                $0.wrappedValue.title.lowercased().contains(formattedSearchString()) ||
                $0.wrappedValue.content.lowercased().contains(formattedSearchString())
            }), id: \.wrappedValue.id) { $post in
                PostPreviewView(post: $post, posts: $posts)
            }
            if searchString.isEmpty {
                ForEach(0..<3) { index in
                    PostPreviewPlaceholderView()
                        .overlay { GeometryReader { proxy in
                            Color.white.opacity(0.001)
                                .onChange(of: proxy.frame(in: .named("scroll"))) { _ in
                                    if index == 0 {
                                        loadNextPosts()
                                    }
                                }
                        }}
                }
            }
        }
        .coordinateSpace(name: "scroll")
        .listStyle(.inset)
        .searchable(text: $searchString)
        .navigationTitle("Announcements")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showFilterView.toggle()
                } label: {
                    ZStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        if let number = numberOfFilters(pinnedTo: 0..<51), number != 0 {
                            Image(systemName: "\(number).circle.fill")
                                .scaleEffect(.init(0.5))
                                .background {
                                    Circle()
                                        .foregroundColor(.white)
                                        .scaleEffect(.init(0.55))
                                }
                                .offset(x: 7, y: 7)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadNextPosts()
        }
    }

    func formattedSearchString() -> String {
        // get rid of filters in the search bar
        searchString.lowercased()
    }

    func numberOfFilters(pinnedTo range: Range<Int>? = nil) -> Int {
        var tags: [String] = []
        for post in posts {
            tags.append(contentsOf: post.categories)
            tags.append(contentsOf: post.userCategories?.map({ $0.name }) ?? [])
        }

        let rawCount = tags.removingDuplicates().filter({ tag in
            searchString.contains("[\(tag)]")
        }).count

        if let range {
            // pin the number to a specified lowerbound and upperbound
            return max(range.lowerBound, min(range.upperBound, rawCount))
        }

        return rawCount
    }

    func loadNextPosts(count: Int = 10) {
        loadQueue.async {
            guard !isLoading else { return }

            isLoading = true
            let range = self.posts.count..<self.posts.count + count
            self.posts.append(contentsOf: PostManager.getPosts(range: range))

            // implement some debounce to prevent too many loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
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
