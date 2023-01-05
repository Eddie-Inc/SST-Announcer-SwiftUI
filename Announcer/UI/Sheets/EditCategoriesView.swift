//
//  EditCategoriesView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 5/1/23.
//

import SwiftUI

struct EditCategoriesView: View {

    @Binding
    var post: Post

    @Binding
    var posts: [Post]

    @State var showCreateNewCategoryAlert: Bool = false
    @State var newCategoryName: String = ""

    @Binding
    var showEditCategoryView: Bool

    var body: some View {
        List {
            // todo: use list of all user categories
            ForEach(PostManager.userCategories, id: \.id) { category in
                categoryView(category: category)
            }
            .onDelete { indexSet in
                PostManager.userCategories.remove(atOffsets: indexSet)
                PostManager.trimDeadUserCategories(from: &posts)
            }
            .onMove { indexSet, moveTo in
                PostManager.userCategories.move(fromOffsets: indexSet,
                                                toOffset: moveTo)
            }
        }
        .searchable(text: .constant(""))
        .navigationTitle("Select Category")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreateNewCategoryAlert.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Create New Category", isPresented: $showCreateNewCategoryAlert) {
            createCategoryAlert
        }
    }

    func categoryView(category: UserCategory) -> some View {
        Button {
            var categories = post.userCategories ?? []

            if categories.contains(category) {
                // remove the category if its already there
                categories.removeAll(where: { $0 == category })
            } else {
                // add the category if its not there yet
                categories.append(category)
            }

            post.userCategories = categories
            PostManager.savePost(post: post)
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .opacity((post.userCategories?.contains(category) ?? false) ? 1 : 0)
                Text(category.name)
            }
            .foregroundColor(.primary)
        }
    }

    @ViewBuilder
    var createCategoryAlert: some View {
        TextField("Name of New Category", text: $newCategoryName)
        Button("Cancel") {
            showEditCategoryView = false
        }
        Button("Create") {
            guard !newCategoryName.isEmpty else { return }
            var categories = post.userCategories ?? []
            categories.append(.init(newCategoryName))
            post.userCategories = categories

            if !PostManager.userCategories.contains(where: {
                $0.name == newCategoryName
            }) {
                PostManager.userCategories.append(.init(newCategoryName))
            }
            showEditCategoryView = false
            PostManager.savePost(post: post)
        }
    }
}

struct EditCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        EditCategoriesView(post: .constant(
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
                    .init(name: "placeholder")
                 ])),
                           posts: .constant([]),
                           showEditCategoryView: .constant(true))
    }
}
