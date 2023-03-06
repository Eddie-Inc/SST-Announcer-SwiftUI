//
//  EditCategoriesView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 5/1/23.
//

import SwiftUI
import PostManager

struct EditCategoriesView: View {

    @Binding
    var post: Post

    @Binding
    var posts: [Post]

    @Binding
    var showEditCategoryView: Bool

    @State var showCreateNewCategoryAlert: Bool = false
    @State var newCategoryName: String = ""

    @State var searchString: String = ""

    var body: some View {
        List {
            if !searchString.isEmpty {
                Section {
                    Button("Create Category \"\(searchString)\"") {
                        createCategory(named: searchString)
                    }
                    .foregroundColor(.accentColor)
                }
            }

            Section {
                ForEach(PostManager.userCategoriesFlat, id: \.id) { category in
                    categoryView(category: category)
                }
                .onDelete { indexSet in
                    // get the categories and stuff to remove
                    let toRemove = PostManager.userCategoriesFlat.enumerated().filter { (index, _) in
                        indexSet.contains(index)
                    }.map { $1 }

                    // remove them from PostManager, then apply the changes
                    var categories = PostManager.userCategoriesForPosts
                    for postTitle in categories.keys {
                        categories[postTitle]?.removeAll(where: { category in
                            toRemove.contains(category)
                        })
                    }
                    PostManager.userCategoriesForPosts = categories

                    // remove them from posts
                    for index in 0..<posts.count {
                        posts[index].userCategories?.removeAll(where: { category in
                            toRemove.contains(category)
                        })
                    }
                }
            }
        }
        .searchable(text: $searchString)
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
//        .alert("Edit Name", isPresented: $showEditSingleCategory) {
//            TextField("Name", text: $categoryName)
//            Button("Cancel") {}
//            Button("Confirm") {
//                guard let index = PostManager.userCategories.firstIndex(where: {
//                    $0.name == originalName
//                }) else { return }
//
//                Log.info("Original name!")
//
//                [index].name = categoryName
//                PostManager.trimDeadUserCategories(from: &posts)
//            }
//        }
    }

    func categoryView(category: UserCategory) -> some View {
        Button {
            var categories = post.userCategories ?? []

            if categories.contains(where: { $0.name == category.name }) {
                // remove the category if its already there
                categories.removeAll(where: { $0 == category })
            } else {
                // add the category if its not there yet
                categories.append(category)
            }

            post.userCategories = categories
            PostManager.userCategoriesForPosts[post.postTitle] = categories
            PostManager.savePost(post: post)
        } label: {
            HStack {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .opacity((post.userCategories?.contains(where: {
                        $0.name == category.name
                    }) ?? false) ? 1 : 0)
                Text(category.name)
            }
            .foregroundColor(.primary)
        }
//        .contextMenu {
//            Button("Edit Category Name") {
//                originalName = category.name
//                categoryName = category.name
//                showEditSingleCategory.toggle()
//            }
//        }
    }

    @ViewBuilder
    var createCategoryAlert: some View {
        TextField("Name of New Category", text: $newCategoryName)
        Button("Cancel") {
            showEditCategoryView = false
        }
        Button("Create") {
            createCategory(named: newCategoryName)
        }
    }

    func createCategory(named: String) {
        guard !named.isEmpty else { return }
        var categories = post.userCategories ?? []
        categories.append(.init(named))
        post.userCategories = categories

        if !PostManager.userCategories.contains(where: {
            $0.name == named
        }) {
            var categories = PostManager
                .userCategoriesForPosts[post.postTitle] ?? []
            categories.append(.init(named))

            PostManager.userCategoriesForPosts[post.postTitle] = categories
        }
        showEditCategoryView = false
        PostManager.savePost(post: post)
    }
}

struct EditCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditCategoriesView(post: .constant(
                Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                     content: placeholderTextLong,
                     date: .now,
                     blogURL: nil,
                     categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ])),
                               posts: .constant([]),
                               showEditCategoryView: .constant(true))
        }
    }
}
