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

    var body: some View {
        List {
            VStack(alignment: .leading) {
                title
                categories
                timeAndReminder
            }

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

                } label: {
                    Image(systemName: "pin")
                }
            }
        }
        .onAppear {
            post.read = true
        }
    }

    var title: some View {
        // title and safari icon
        HStack {
            Text(post.title)
                .bold()
                .multilineTextAlignment(.leading)
            Spacer()
            VStack {
                Button {
                    // open in safari
                } label: {
                    Image(systemName: "safari")
                        .opacity(0.6)
                }
                Spacer()
            }
        }
        .font(.title2)
        .padding(.bottom, -5)
    }

    var categories: some View {
        // categories
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
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
    }

    var timeAndReminder: some View {
        // post and reminder
        HStack {
            Image(systemName: "timer")
            Text("03 Jan 2023")
                .padding(.trailing, 10)
            Image(systemName: "alarm")
            Text("8h")
        }
        .font(.subheadline)
        .padding(.bottom, 5)
    }

    var bodyText: some View {
        // body text
        // TODO: Make this compatable with html text
        VStack {
            Text(post.content)
            Spacer()
        }
        .padding(.top, 10)
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
                     ])))
        }
    }
}
