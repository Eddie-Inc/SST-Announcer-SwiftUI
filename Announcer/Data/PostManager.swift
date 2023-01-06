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
        for postIndex in 0..<posts.count {
            // get the categories, if there are none (is nil or []) then continue
            guard var newCategories: [UserCategory?] = posts[postIndex].userCategories,
                  !newCategories.isEmpty
            else { continue }

            // iterate over user categories in each post
            for categoryIndex in 0..<newCategories.count {
                guard let category = newCategories[categoryIndex] else { return }

                if let userCategory = userCategories.first(where: { $0.id == category.id }) {
                    // if user categories contains an item with the same ID, then that
                    // means that the category is valid. Keep the name updated.
                    newCategories[categoryIndex]?.name = userCategory.name
                } else {
                    // if the userCategories does not contain a category with the same ID,
                    // then remove the item
                    newCategories[categoryIndex] = nil
                }
            }

            posts[postIndex].userCategories = newCategories.compactMap({ $0 })
        }
    }

    /// Saves a post to localstorage. Effectively a form of cache.
    static func savePost(post: Post) {

    }

    static var userCategories: [UserCategory] {
        get {
            // load from userDefaults or cache
            if let userCategories = _userCategories {
                return userCategories
            }

            // Retrieve from UserDefaults
            if let data = UserDefaults.standard.object(forKey: .userCategories) as? Data {
                if let values = try? JSONDecoder().decode([UserCategory].self, from: data) {
                    return values
                }
            } else {
                // reset it
                defaults.set(nil, forKey: .userCategories)
            }

            return []
        }
        set {
            _userCategories = newValue
            // save to userDefaults
            // To store in UserDefaults
            if let encoded = try? JSONEncoder().encode(newValue) {
                defaults.set(encoded, forKey: .userCategories)
            }
        }
    }

    private static var _userCategories: [UserCategory]?
}

extension String {
    static let userCategories = "userCategories"
}
