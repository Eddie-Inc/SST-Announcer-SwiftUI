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
    var possibleTags: [String]

    @Binding
    var searchString: String

    init(posts: [Post], searchString: Binding<String>) {
        self.posts = posts
        self._searchString = searchString

        var tags: Set<String> = .init()
        for post in posts {
            for category in post.categories {
                tags.insert(category)
            }
        }

        self.possibleTags = Array(tags).sorted(by: <)
    }

    var body: some View {
        List {
            ForEach($possibleTags, id: \.self) { $tag in
                Button {
                    // add or remove the tag from the search term
                    if searchString.contains("[\(tag)]") {
                        searchString = searchString.replacingOccurrences(of: "[\(tag)]",
                                                                         with: "")
                    } else {
                        searchString = "[\(tag)] \(searchString)"
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .opacity(searchString.contains("[\(tag)]") ? 1 : 0)
                        Text(tag)
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
        ], searchString: .constant("no"))
    }
}
