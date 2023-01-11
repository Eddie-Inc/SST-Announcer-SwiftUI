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
            if let posts = read([PostTitle].self, from: "readPosts.json") {
                _readPosts = Set(posts)
                return Set(posts)
            }

            return .init()
        }
        set {
            _readPosts = newValue
            loadQueue.async {
                // TODO: Reduce the frequency of this.
                // As the set gets larger, this will become a more and more expensive task to do.
                // save to file system
                write(Array(newValue), to: "readPosts.json")
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
            if let categories = read([String: [UserCategory]].self, from: "userCategories.json") {
                _userCategories = categories
                return categories
            }

            return [:]
        }
        set {
            _userCategories = newValue
            // save to file system
            write(newValue, to: "userCategories.json")
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
