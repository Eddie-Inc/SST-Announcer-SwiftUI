//
//  CachePostsView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 20/1/23.
//

import SwiftUI
import PostManager

struct CachePostsView: View {
    @State var postsToCache: Double = 400
    @State var numberOfCachedPosts = PostManager.postStorage.count

    @State var isLoading: Bool = false

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Text("NOTE:\n")
                        .foregroundColor(.green)
                        .bold()
                    +
                    Text("""
Cached posts are available offline because they are saved in your device's hard drive.
If you cache too many posts, the app size will increase and you may feel lag while searching or filtering posts.

Not all posts will be loaded and cached instantaneously.
You may need to relaunch the app for the settings view to accurately reflect the new number of cached posts.
""")
                    Spacer()
                }
                .multilineTextAlignment(.center)

                HStack {
                    Text("Number of cached posts:")
                    Spacer()
                    Text("\(numberOfCachedPosts)")
                        .foregroundColor(.secondary)
                }
            }

            Section {
                VStack {
                    Text("Posts to cache: \(Int(postsToCache))")
                    Slider(value: $postsToCache, in: 50...2000, step: 50)
                }
                    Button {
                        let count = PostManager.postStorage.count
                        let upperBound = count + Int(postsToCache)
                        isLoading = true
                        loadQueue.async {
                            do {
                                try PostManager.loadCachePosts(range: count..<upperBound) {
                                    numberOfCachedPosts = PostManager.postStorage.count
                                }
                                isLoading = false
                            } catch {
                                Log.info("Something happened!")
                                isLoading = false
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cache")
                            if isLoading {
                                Image(systemName: "ellipsis")
                            }
                            Spacer()
                        }
                    }
            }
        }
    }
}

struct CachePostsView_Previews: PreviewProvider {
    static var previews: some View {
        CachePostsView()
    }
}
