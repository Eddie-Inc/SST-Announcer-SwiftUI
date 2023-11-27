//
//  EditFilterView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import SwiftUI
import PostManager

struct EditFilterView: View {

    @State var posts: [Post]

    @State var possibleTags: [String]

    @Binding var filterCategories: [String]

    init(posts: [Post], filterCategories: Binding<[String]>) {
        self.posts = posts
        self._filterCategories = filterCategories

        var tags: [String] = []
        for post in posts {
            tags.append(contentsOf: post.categories)
            tags.append(contentsOf: post.userCategories?.map({ $0.name }) ?? [])
        }

        self.possibleTags = tags.removingDuplicates().sorted(by: <)
    }

    var body: some View {
        List {
            ForEach($possibleTags, id: \.self) { $tag in
                Button {
                    // add or remove the tag from the search term
                    if filterCategories.contains(tag) {
                        filterCategories.removeAll(where: {
                            $0 == tag
                        })
                    } else {
                        filterCategories.append(tag)
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .opacity(filterCategories.contains(tag) ? 1 : 0)
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
                 blogURL: nil,
                 categories: ["Random Category"]),
            Post(title: "\(placeholderTextShort) 2",
                 content: placeholderTextLong,
                 date: .now,
                 blogURL: nil,
                 categories: ["Random Category 2"]),
            Post(title: "\(placeholderTextShort) 3",
                 content: placeholderTextLong,
                 date: .now,
                 blogURL: nil,
                 categories: ["Random Category 3"])
        ], filterCategories: .constant([]))
    }
}
