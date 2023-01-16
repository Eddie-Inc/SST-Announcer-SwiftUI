//
//  Settings.swift
//  Announcer
//
//  Created by Kai Quan Tay on 12/1/23.
//

import SwiftUI
import OrderedCollections

let fakeStorage: OrderedDictionary<PostTitle, Post> =
    .init(uniqueKeys: [PostTitle(date: .now, title: "test")],
          values: [Post(title: "test",
                        content: placeholderTextLong,
                        date: .now,
                        pinned: false,
                        read: true,
                        categories: [])])

struct Settings: View {

    var body: some View {
        List {
            Section {
                Picker("Number of posts per load", selection: .init(get: {
                    SettingsManager.shared.loadNumber
                }, set: { newValue in
                    SettingsManager.shared.loadNumber = newValue
                })) {
                    ForEach(5...150, id: \.self) { number in
                        Text("\(number)")
                    }
                }
            }

            Section("Storage") {
                HStack {
                    Text("Number of cached posts:")
                    Spacer()
                    Text("\(PostManager.postStorage.count)")
//                    Text("\(fakeStorage.count)")
                        .foregroundColor(.secondary)
                }
                if let last = PostManager.postStorage.elements.last {
//                if let last = fakeStorage.elements.last {
                    HStack {
                        Text("Earliest post:")
                        Spacer()
                        Text(last.value.date.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(.secondary)
                    }
                }

                NavigationLink("Clear Storage") {
                    ClearStorageView()
                }
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Settings()
        }
    }
}
