//
//  AnnouncementDetailView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI

struct AnnouncementDetailView: View {
    @Binding
    var post: Post

    @State
    var showAddCategoryView: Bool = false

    var body: some View {
        List {
            title

            categories
                .listRowSeparator(.hidden, edges: .top)

            timeAndReminder
                .offset(y: -3)
                .listRowSeparator(.hidden, edges: .top)

            bodyText
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {

                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    post.pinned.toggle()
                } label: {
                    Image(systemName: post.pinned ? "pin.fill" : "pin")
                }
            }
        }
        .sheet(isPresented: $showAddCategoryView) {
            if #available(iOS 16.0, *) {
                addNewCategory
                    .presentationDetents(Set([.large, .medium]))
            } else {
                // Fallback on earlier versions
                addNewCategory
            }
        }
    }

    var title: some View {
        // title
        HStack {
            Text(post.title)
                .bold()
                .multilineTextAlignment(.leading)
        }
        .font(.title2)
        .padding(.bottom, -5)
    }

    var categories: some View {
        // categories
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let userCategories = post.userCategories {
                        ForEach(userCategories, id: \.self) { category in
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
                    ForEach(post.categories, id: \.self) { category in
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
            Button {
                // add category
                showAddCategoryView.toggle()
            } label: {
                Image(systemName: "plus")
                    .opacity(0.6)
            }
        }
    }

    var timeAndReminder: some View {
        // post and reminder
        HStack {
            Image(systemName: "timer")
            Text("03 Jan 2023")
                .padding(.trailing, 10)
            Image(systemName: "alarm")
            Text("8h")

            Spacer()
        }
        .font(.subheadline)
    }

    var links: some View {
        // if it has links
        VStack(alignment: .leading) {
            Text("Links")
                .bold()
            ForEach(["https://www.youtube.com", "https://www.google.com"], id: \.self) { url in
                Text(url)
                    .underline()
                    .foregroundColor(.accentColor)
            }
        }
    }

    var bodyText: some View {
        // body text
        // TODO: Make this compatable with html text
        VStack {
            Text(post.content)
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                // open in safari
            } label: {
                Image(systemName: "arrow.up.forward.circle")
                    .opacity(0.6)
                    .offset(x: 6, y: 3)
            }
        }
        .padding(.top, 10)
    }

    @State var showCreateNewCategoryAlert: Bool = false
    @State var newCategoryName: String = ""
    var addNewCategory: some View {
        NavigationView {
            List {
                // todo: use list of all user categories
                if let categories = PostManager.userCategories {
                    ForEach(categories, id: \.self) { name in
                        Button {
                            var categories = post.userCategories ?? []

                            if categories.contains(name) {
                                // remove the category if its already there
                                categories.removeAll(where: { $0 == name })
                            } else {
                                // add the category if its not there yet
                                categories.append(name)
                            }

                            post.userCategories = categories
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .opacity((post.userCategories?.contains(name) ?? false) ? 1 : 0)
                                Text(name)
                            }
                            .foregroundColor(.primary)
                        }
                    }
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
                TextField("Name of New Category", text: $newCategoryName)
                Button("Cancel") {
                    showAddCategoryView = false
                }
                Button("Create") {
                    guard !newCategoryName.isEmpty else { return }
                    var categories = post.userCategories ?? []
                    categories.append(newCategoryName)
                    post.userCategories = categories

                    if !PostManager.userCategories.contains(newCategoryName) {
                        PostManager.userCategories.append(newCategoryName)
                    }
                    showAddCategoryView = false
                }
            }
        }
    }
}

struct AnnouncementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementDetailView(post: .constant(
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
}
