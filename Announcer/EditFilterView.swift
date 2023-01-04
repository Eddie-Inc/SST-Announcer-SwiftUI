//
//  EditFilterView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import SwiftUI

struct EditFilterView: View {

    @State
    var posts: [Post]

    @State
    var possibleTags: [(name: String, isActive: Bool)]

    init(posts: [Post]) {
        self.posts = posts

        var tags: Set<String> = .init()
        for post in posts {
            for category in post.categories {
                tags.insert(category)
            }
        }

        self.possibleTags = Array(tags).sorted(by: <).map { name in
            (name, false)
        }
    }

    var body: some View {
        List {
            ForEach($possibleTags, id: \.0) { $tag in
                Button {
                    tag.1.toggle()
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .opacity(tag.1 ? 1 : 0)
                        Text(tag.0)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

struct EditFilterView_Previews: PreviewProvider {
    static var previews: some View {
        EditFilterView(posts: [
            Post(title: "\(placeholderTextShort) 1",
                 content: placeholderTextLong,
                 date: .now,
                 pinned: true,
                 read: false,
                 categories: ["Random Category"]),
            Post(title: "\(placeholderTextShort) 2",
                 content: placeholderTextLong,
                 date: .now,
                 pinned: false,
                 read: true,
                 categories: ["Random Category 2"]),
            Post(title: "\(placeholderTextShort) 3",
                 content: placeholderTextLong,
                 date: .now,
                 pinned: false,
                 read: false,
                 categories: ["Random Category 3"])
        ])
    }
}
