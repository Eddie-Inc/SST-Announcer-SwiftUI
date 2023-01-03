//
//  AnnouncementsHomeView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI

let placeholderTextShort = "Lorem ipsum dolor sit amet"
let placeholderTextLong = """
Dear Students,

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt \
ut labore et dolore magna aliqua. Turpis egestas pretium aenean pharetra. Orci eu lobortis.

elementum nibh tellus molestie. Vulputate dignissim suspendisse in est. Vel pharetra vel \
turpis nunc. Malesuada nunc vel risus commodo. Nisi vitae suscipit tellus mauris.

Posuere orbi leo urna molestie at elementum eu. Urna duis convallis convallis tellus. Urna molestie \
at elementum eu. Nunc sed blandit libero volutpat.
"""

struct AnnouncementsHomeView: View {
    @State
    var prototypePosts: [Post] = [
        Post(title: "\(placeholderTextShort) 1",
             content: placeholderTextLong,
             date: .now,
             pinned: true,
             read: false,
             categories: ["Random Category"]),
        Post(title: "\(placeholderTextShort) 2",
             content: placeholderTextLong,
             date: .now,
             pinned: false,
             read: true,
             categories: ["Random Category"]),
        Post(title: "\(placeholderTextShort) 3",
             content: placeholderTextLong,
             date: .now,
             pinned: false,
             read: false,
             categories: ["Random Category"])
    ]

    var body: some View {
        List {
            ForEach(prototypePosts, id: \.title) { post in
                VStack(alignment: .leading) {
                    HStack {
                        if post.pinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.accentColor)
                                .font(.footnote)
                                .padding(.trailing, -4)
                        }
                        Text(post.title)
                            .lineLimit(2)
                    }
                    .padding(.bottom, 0.5)
                    Text(post.content)
                        .opacity(post.read ? 0.3 : 0.6)
                        .lineLimit(4)
                }
            }
        }
        .listStyle(.inset)
        .searchable(text: .constant(""))
        .navigationTitle("Announcements")
    }
}

struct AnnouncementsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementsHomeView()
        }
    }
}
