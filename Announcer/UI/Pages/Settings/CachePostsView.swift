//
//  CachePostsView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 20/1/23.
//

import SwiftUI

struct CachePostsView: View {
    @State var postsToCache: Double = 400

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
""")
                    Spacer()
                }
                .multilineTextAlignment(.center)

                HStack {
                    Text("Number of cached posts:")
                    Spacer()
                    Text("\(PostManager.postStorage.count)")
                        .foregroundColor(.secondary)
                }
            }

            Section {
                VStack {
                    Text("Posts to cache: \(Int(postsToCache))")
                    Slider(value: $postsToCache, in: 100...2000, step: 100)
                }
                HStack {
                    Spacer()
                    Button("Cache") {
                    }
                    Spacer()
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
