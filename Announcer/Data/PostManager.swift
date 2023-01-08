//
//  PostManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import Foundation

var defaults = UserDefaults.standard

enum PostManager {

    // MARK: Getting posts
    static func getPosts(range: Range<Int>) -> [Post] {
        // account for the pinned posts
        let pinnedPosts = pinnedPosts

        var posts: [Post] = []

        // if range.lowerBound is < pinnedPosts.count, then
        // add the pinned posts and fetch the remainder
        if range.lowerBound < pinnedPosts.count {
            let upperBound = min(pinnedPosts.count, range.upperBound)
            posts = Array(pinnedPosts[range.lowerBound..<upperBound])
        }

        // if there are still posts that need to be fetched, fetch them
        if posts.count < range.count {
            posts = fetchValues(range: posts.count..<range.upperBound)
        }
        trimDeadUserCategories(from: &posts)

        return posts
    }

    // MARK: Post processing
    // pun intended
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

    // MARK: Persistence
    static var readPosts: Set<String> {
        get {
            if let posts = _readPosts {
                return posts
            } else if let defaultsPosts = defaults.stringArray(forKey: .readPosts) {
                _readPosts = .init(defaultsPosts)
                return .init(defaultsPosts)
            }

            return .init()
        }
        set {
            _readPosts = newValue
            loadQueue.async {
                // TODO: Reduce the frequency of this.
                // As the set gets larger, this will become a more and more expensive task to do.
                defaults.set(Array(newValue), forKey: .readPosts)
            }
        }
    }
    private static var _readPosts: Set<String>?

    static var pinnedPosts: [Post] {
        get {
            if let posts = _pinnedPosts {
                return posts
            } else if let defaultPosts = defaults.array(forKey: .pinnedPosts) as? [Post] {
                _pinnedPosts = defaultPosts
                return defaultPosts
            }

            return []
        }
        set {
            _pinnedPosts = newValue
            loadQueue.async {
                defaults.set(newValue, forKey: .pinnedPosts)
            }
        }
    }
    private static var _pinnedPosts: [Post]?

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
    static let readPosts = "readPosts"
    static let pinnedPosts = "pinnedPosts"
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
