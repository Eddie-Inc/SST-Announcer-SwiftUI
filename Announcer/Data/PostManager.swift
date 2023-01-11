//
//  PostManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import Foundation
import SwiftUI

var defaults = UserDefaults.standard

enum PostManager {
    static var readPosts: Set<PostTitle> {
        get {
            if let posts = _readPosts {
                return posts
            }

            // Retrieve from file
            let filename = getDocumentsDirectory().appendingPathComponent("readPosts.json")
            if let data = try? Data(contentsOf: filename) {
                if let values = try? JSONDecoder().decode([PostTitle].self, from: data) {
                    Log.info("Read posts data found! \(values)")
                    _readPosts = Set(values)
                    return Set(values)
                }
            } else {
                // reset it
                Log.info("Values not found :(")
            }

            return .init()
        }
        set {
            _readPosts = newValue
            loadQueue.async {
                // TODO: Reduce the frequency of this.
                // As the set gets larger, this will become a more and more expensive task to do.
                // save to file system
                if let encoded = try? JSONEncoder().encode(Array(newValue)) {
                    let filename = getDocumentsDirectory().appendingPathComponent("readPosts.json")
                    do {
                        try encoded.write(to: filename)
                        Log.info("Successfully wrote \(encoded) (from \(newValue)) to \(filename.description)")
                    } catch {
                        // failed to write file – bad permissions, bad filename,
                        // missing permissions, or more likely it can't be converted to the encoding
                        Log.info("Failed to write to file!")
                    }
                }
            }
        }
    }
    private static var _readPosts: Set<PostTitle>?

    static func getPosts(range: Range<Int>) -> [Post] {
        let posts = fetchValues(range: range)

        return posts
    }

    /// Saves a post to localstorage. Effectively a form of cache.
    static func savePost(post: Post) {
    }

    static var userCategories: [UserCategory] {
        // flatten user categories for posts
        let categories = userCategoriesForPosts
        return categories.flatMap({ $1 })
    }

    static var userCategoriesForPosts: [String: [UserCategory]] {
        get {
            // load from userDefaults or cache
            if let userCategories = _userCategories {
                return userCategories
            }

            // Retrieve from file
            let filename = getDocumentsDirectory().appendingPathComponent("userCategories.json")
            if let data = try? Data(contentsOf: filename) {
                if let values = try? JSONDecoder().decode([String: [UserCategory]].self, from: data) {
                    Log.info("Values found!")
                    _userCategories = values
                    return values
                }
            } else {
                // reset it
                Log.info("Values not found :(")
            }

            return [:]
        }
        set {
            _userCategories = newValue
            // save to file system
            if let encoded = try? JSONEncoder().encode(newValue) {
                let filename = getDocumentsDirectory().appendingPathComponent("userCategories.json")
                do {
                    try encoded.write(to: filename)
                    Log.info("Successfully wrote \(encoded) (from \(newValue)) to \(filename.description)")
                } catch {
                    // failed to write file – bad permissions, bad filename,
                    // missing permissions, or more likely it can't be converted to the encoding
                    Log.info("Failed to write to file!")
                }
            }
        }
    }

    private static var _userCategories: [String: [UserCategory]]?
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

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
