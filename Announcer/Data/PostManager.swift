//
//  PostManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import Foundation
import SwiftUI
import OrderedCollections

enum PostManager {
    // MARK: Getting/saving posts
    static func getPosts(range: Range<Int>) -> [Post] {
        var posts: [Post] = []
        do {
            posts = try fetchValues(range: range)
            loadQueue.async {
                addPostsToStorage(newItems: posts)
            }
        } catch {
            Log.info("could not get values. Attempting to use cache.")
            let storage = postStorage

            guard !storage.isEmpty else {
                Log.info("No items in cache")
                return []
            }

            let values = storage.values

            if range.lowerBound >= 0 && range.upperBound > range.lowerBound {
                let newUpper = min(range.upperBound, values.count)
                return Array(values[range.lowerBound..<newUpper])
            }
        }

        return posts
    }

    /// Saves a post to localstorage. Effectively a form of cache.
    static func savePost(post: Post) {
    }

    // MARK: Read posts
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

    // TODO: Reminder Dates
    static var reminderDates: [PostTitle: Date] {
        get {
            // load from cache
            if let dates = _reminderDates {
                return dates
            }

            // Retrieve from file
            if let dates = read([PostTitle: Date].self, from: "reminderDates.json") {
                _reminderDates = dates
                return dates
            }

            return [:]
        }
        set {
            _reminderDates = newValue
            write(newValue, to: "reminderDates.json")
        }
    }
    private static var _reminderDates: [PostTitle: Date]?

    // MARK: User categories
    static var userCategories: [UserCategory] {
        // flatten user categories for posts
        let categories = userCategoriesForPosts
        return categories.flatMap({ $1 })
    }

    static var userCategoriesForPosts: [PostTitle: [UserCategory]] {
        get {
            // load from cache
            if let userCategories = _userCategories {
                return userCategories
            }

            // Retrieve from file
            if let categories = read([PostTitle: [UserCategory]].self, from: "userCategories.json") {
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

    private static var _userCategories: [PostTitle: [UserCategory]]?

    static var postStorage: OrderedDictionary<PostTitle, Post> {
        get {
            if let posts = _postStorage {
                return posts
            }

            if let posts = read(OrderedDictionary<PostTitle, Post>.self, from: "postStorage.json") {
                _postStorage = posts
                return posts
            }

            return .init()
        }
        set {
            _postStorage = newValue
            // save to file system
            write(newValue, to: "postStorage.json")
        }
    }
    private static var _postStorage: OrderedDictionary<PostTitle, Post>?
}

// MARK: Placeholder text
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
