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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                if let userCategories = post.userCategories {
                    ForEach(userCategories.sorted(by: <), id: \.self) { category in
                        Text(category)
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
        .cornerRadius(5)
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
                     "placeholder"
                 ])))
    }
}
