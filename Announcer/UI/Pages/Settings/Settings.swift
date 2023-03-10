//
//  Settings.swift
//  Announcer
//
//  Created by Kai Quan Tay on 12/1/23.
//

import SwiftUI
import OrderedCollections
import PostManager

let fakeStorage: OrderedDictionary<PostTitle, Post> =
    .init(uniqueKeys: [PostTitle(date: .now, title: "test")],
          values: [Post(title: placeholderTextShort,
                        content: placeholderTextLong,
                        date: .now,
                        blogURL: nil,
                        categories: [])])

struct Settings: View {

    @StateObject
    var settings: SettingsManager = .shared

    var body: some View {
        List {
            Section("Post Loading") {
                Picker("Number of posts per load",
                       selection: $settings.loadNumber) {
                    ForEach(5...150, id: \.self) { number in
                        Text("\(number)")
                    }
                }
            }

            Section("Search") {
                Picker("Number of posts per load when searching",
                       selection: $settings.searchLoadNumber) {
                    ForEach(5...150, id: \.self) { number in
                        Text("\(number)")
                    }
                }
                Toggle("When searching for keyword, search post content",
                       isOn: $settings.searchPostContent)
            }

            Section("Storage") {
                HStack {
                    Text("Number of cached posts:")
                    Spacer()
                    Text("\(PostManager.postStorage.count)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Space used by cached posts:")
                    Spacer()
                    Text("\(getDocumentsDirectory().appendingPathComponent("postStorage.json").fileSizeString)")
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

                NavigationLink("Cache more posts") {
                    CachePostsView()
                }

                NavigationLink("Clear Storage") {
                    ClearStorageView()
                }
            }

            Section {
                Toggle("Debug Mode", isOn: $settings.debugMode)
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
