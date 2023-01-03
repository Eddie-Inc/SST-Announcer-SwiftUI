//
//  AnnouncementDetailView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI

struct AnnouncementDetailView: View {
    @State
    var post: Post

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
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
                .padding(.bottom, 0)

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

                // post and reminder
                HStack {
                    Image(systemName: "alarm")
                    Text("03 Jan 2023")
                        .padding(.trailing, 10)
                    Image(systemName: "timer")
                    Text("8h")
                }
                .font(.subheadline)

                Divider()
                    .padding(.vertical, 5)

                // body text
                // TODO: Make this compatable with html text
                Text(post.content)
            }
            .padding(15)
        }
//        .background {
//            Color.yellow
//        }
        .navigationTitle("")
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
    }
}

struct AnnouncementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementDetailView(post: Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                                              content: placeholderTextLong,
                                              date: .now,
                                              pinned: true,
                                              read: false,
                                              categories: [
                                                "short",
                                                "secondary 3",
                                                "you wanted more?"
                                              ]))
        }
    }
}
