//
//  CategoryScrollView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 5/1/23.
//

import SwiftUI

struct CategoryScrollView: View {
    @Binding
    var post: Post

    var body: some View {
        if (post.userCategories?.isEmpty ?? true) &&
            post.categories.isEmpty {
            HStack {
                Text("No Categories")
                    .font(.subheadline)
                Spacer()
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                scrollContent
            }
            .cornerRadius(5)
        }
    }

    var scrollContent: some View {
        HStack {
            if let userCategories = post.userCategories {
                ForEach(userCategories.sorted(by: { $0.name < $1.name }), id: \.id) { category in
                    Text(category.name)
                        .font(.subheadline)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 5)
                        .background {
                            Rectangle()
                                .foregroundColor(.orange)
                                .opacity(0.5)
                                .cornerRadius(5)
                        }
                }
            }
            ForEach(post.categories.sorted(by: <), id: \.self) { category in
                Text(category)
                    .font(.subheadline)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 5)
                    .background {
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .opacity(0.5)
                            .cornerRadius(5)
                    }
            }
        }

    }
}

struct CategoryScrollView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryScrollView(post: .constant(
            Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                 content: placeholderTextLong,
                 date: .now,
                 pinned: true,
                 read: false,
                 categories: [
                     "short",
                     "secondary 3",
                     "you wanted more?"
                 ],
                 userCategories: [
                    .init("placeholder")
                 ])))
    }
}
