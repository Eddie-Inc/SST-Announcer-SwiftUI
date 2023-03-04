//
//  AnnouncementsHomeView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI
import PostManager

struct AnnouncementsHomeView: View {

    @State
    var posts: [Post] = []

    @State
    var showFilterView: Bool = false

    @State
    var filterCategories: [String] = []

    @State
    var searchString: String = ""

    @State
    var searchScope: String = ""

    @State
    var isLoading: Bool = false

    @StateObject
    var settings: SettingsManager = .shared

    var body: some View {
        if #available(iOS 16.0, *) {
            content
                .sheet(isPresented: $showFilterView) {
                    EditFilterView(posts: posts,
                                   filterCategories: $filterCategories)
                        .presentationDetents(Set([.medium, .large]))
                }
        } else {
            content
                .sheet(isPresented: $showFilterView) {
                    EditFilterView(posts: posts,
                                   filterCategories: $filterCategories)
                }
        }
    }

    var content: some View {
        List {
            ForEach($posts.filter({ shouldPostBeIncluded(post: $0.wrappedValue) }),
                    id: \.wrappedValue.id) { $post in
                PostPreviewView(post: $post, posts: $posts)
            }
            if searchString.isEmpty && filterCategories.isEmpty {
                autoLoadSkeleton
            } else {
                Button {
                    loadNextPosts(count: settings.searchLoadNumber)
                } label: {
                    loadNextButton
                }
                .foregroundColor(.accentColor)
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
            loadNextPosts(count: settings.loadNumber)
        }
    }

    var autoLoadSkeleton: some View {
        ForEach(0..<3) { index in
            PostPreviewPlaceholderView()
                .overlay { GeometryReader { proxy in
                    Color.white.opacity(0.001)
                        .onChange(of: proxy.frame(in: .named("scroll"))) { _ in
                            if index == 0 {
                                loadNextPosts(count: settings.loadNumber)
                            }
                        }
                }}
        }
    }

    var loadNextButton: some View {
        HStack {
            Spacer()
            Text("Search older posts")
            if isLoading {
                Image(systemName: "ellipsis")
            }
            Spacer()
        }
    }

    func shouldPostBeIncluded(post: Post) -> Bool {
        let searchIsEmpty = searchString.isEmpty
        let containsInTitle = post.title.lowercased().contains(formattedSearchString())
        let containsInContent = settings.searchPostContent &&
            post.content.lowercased().contains(formattedSearchString())

        let tagsAreEmpty = filterCategories.isEmpty
        let containsTag = filterCategories.contains(where: { tag in
            (post.userCategories?.contains(where: { $0.name == tag }) ?? false ) ||
            post.categories.contains(where: { $0 == tag })
        })

        let searchWorks = searchIsEmpty || containsInTitle || containsInContent
        let tagWorks = tagsAreEmpty || containsTag
        return searchWorks && tagWorks
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

    func loadNextPosts(count: Int) {
        loadQueue.async {
            guard !isLoading else { return }

            isLoading = true
            let range = self.posts.count..<self.posts.count + count
            self.posts.append(contentsOf: PostManager.getPosts(range: range))

            // implement some debounce to prevent too many loads
            DispatchQueue.main.asyncAfter(deadline: .now() + 500) {
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
