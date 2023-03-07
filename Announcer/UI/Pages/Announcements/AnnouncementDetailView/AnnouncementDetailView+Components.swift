//
//  AnnouncementDetailView+Components.swift
//  Announcer
//
//  Created by Kai Quan Tay on 8/1/23.
//

import SwiftUI
import PostManager

extension AnnouncementDetailView {
    @ViewBuilder
    var title: some View {
        VStack {
            // title
            HStack {
                Text(post.title)
                    .bold()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .font(.title2)
            .padding(.bottom, 8)
            if let authors = post.authors {
                HStack {
                    ForEach(authors, id: \.self) { author in
                        Text(author)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.top, -8)
            }
        }
    }

    @ViewBuilder
    var categories: some View {
        // categories
        if !(post.userCategories?.isEmpty ?? true) {
            // only show categories if available
            HStack {
                CategoryScrollView(post: $post)
                    .font(.subheadline)
            }
            .onTapGesture {
                showEditCategoryView.toggle()
            }
            .buttonStyle(.plain)
            .offset(y: -3)
        } else {
            Spacer()
                .frame(height: 10)
        }
    }

    var postAndReminder: some View {
        HStack {
            TimeAndReminder(post: $post)
                .font(.subheadline)
                .onTapGesture {
                    showEditReminderDateView.toggle()
                }
                .buttonStyle(.plain)
            Spacer()
        }
    }

    var links: some View {
        VStack(alignment: .leading) {
            Text("Links")
                .bold()
                .padding(.bottom, 5)
            LazyVGrid(columns: .init(repeating: .init(), count: 2)) {
                ForEach(0..<metadatas.count, id: \.self) { index in
                    LinkPreview(metadata: metadatas.values[index])
                        .frame(height: 80)
                }
            }
            .frame(minHeight: CGFloat((metadatas.count+1)/2) * 80)
            ForEach(post.getLinks(), id: \.absoluteString) { url in
                if metadatas[url] == nil {
                    Text(url.description)
                        .underline()
                        .foregroundColor(.accentColor)
                        .lineLimit(1)
                        .onTapGesture {
                            safariViewURL = url
                            showSafariView = true
                        }
                        .onAppear {
                            LinkPreview.fetchMetadata(for: url) { result in
                                switch result {
                                case .success(let success):
                                    metadatas[url] = success
                                case .failure(let failure):
                                    print("Failure: \(failure)")
                                }
                            }
                        }
                }
            }
        }
    }

    var addNewCategory: some View {
        NavigationView {
            EditCategoriesView(post: $post,
                               posts: $posts,
                               showEditCategoryView: $showEditCategoryView)
        }
    }

    var editReminderDate: some View {
        NavigationView {
            EditReminderDateView(post: $post,
                                 showEditReminderDateView: $showEditReminderDateView)
        }
    }
}

struct AnnouncementDetailViewComponents_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementDetailView(post: .constant(
                Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                     authors: ["Some Guy"],
                     content: """
\(placeholderTextLong)
<a href=\"https://www.google.com\">
<a href=\"https://www.kagi.com\">
""",
                     date: .now,
                     blogURL: nil,
                     categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ])), posts: .constant([]))
        }
    }
}
