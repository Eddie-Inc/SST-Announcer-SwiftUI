//
//  PostManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import Foundation

private let tempPosts: [Post] = [
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

var defaults = UserDefaults.standard

enum PostManager {
    static func getPosts(range: Range<Int>, completion: (([Post]?, Error?) -> Void)) {
        // pin the range
        let newRange = max(0, range.lowerBound)..<min(tempPosts.count, range.upperBound)

        // iterate over the range and remove user categories if they don't exist
        var posts = Array(tempPosts[newRange])
        trimDeadUserCategories(from: &posts)

        completion(posts, nil)
    }

    static func trimDeadUserCategories(from posts: inout [Post]) {
        for index in 0..<posts.count {
            posts[index].userCategories?.removeAll {
                !userCategories.contains($0)
            }
        }
    }

    /// Saves a post to localstorage. Effectively a form of cache.
    static func savePost(post: Post) {

    }

    static var userCategories: [String] {
        get {
            // load from userDefaults or cache
            if let userCategories = _userCategories {
                return userCategories
            }

            let categories = defaults.stringArray(forKey: .userCategories) ?? []

            return categories
        }
        set {
            _userCategories = newValue
            // save to userDefaults
            defaults.set(newValue, forKey: .userCategories)
        }
    }

    private static var _userCategories: [String]?
}

extension String {
    static let userCategories = "userCategories"
}
