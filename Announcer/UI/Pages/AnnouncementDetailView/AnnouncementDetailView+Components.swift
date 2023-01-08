//
//  AnnouncementDetailView+Components.swift
//  Announcer
//
//  Created by Kai Quan Tay on 8/1/23.
//

import SwiftUI

extension AnnouncementDetailView {
    var title: some View {
        // title
        HStack {
            Text(post.title)
                .bold()
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .font(.title2)
        .padding(.bottom, 8)
        .overlay(alignment: .bottomTrailing) {
            Button {
                // open in safari
                withAnimation(.easeIn(duration: 0.08)) {
                    isLoadingSafariView = true
                }
                loadQueue.async {
                    safariViewURL = post.getBlogURL()
                    isLoadingSafariView = false
                    showSafariView = true
                }
            } label: {
                Image(systemName: "arrow.up.forward.circle")
                    .opacity(0.6)
                    .offset(x: 0, y: -10)
            }
        }
    }

    var categories: some View {
        // categories
        HStack {
            CategoryScrollView(post: $post)
                .font(.subheadline)
            Button {
                // add category
                showEditCategoryView.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .opacity(0.6)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 4)
    }

    var postAndReminder: some View {
        HStack {
            TimeAndReminder(post: $post)
                .font(.subheadline)
            Spacer()
            Button {
                showEditReminderDateView.toggle()
            } label: {
                if post.reminderDate == nil {
                    Image(systemName: "calendar.badge.plus")
                } else {
                    Image(systemName: "slider.horizontal.3")
                }
            }
            .buttonStyle(.plain)
            .opacity(0.6)
        }
    }

    var links: some View {
        VStack(alignment: .leading) {
            ForEach(post.getLinks(), id: \.absoluteString) { url in
                Text(url.description)
                    .underline()
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
                    .onTapGesture {
                        safariViewURL = url
                        showSafariView = true
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
                     content: "<p>\(placeholderTextLong)<p>",
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
                     ])), posts: .constant([]))
        }
    }
}
