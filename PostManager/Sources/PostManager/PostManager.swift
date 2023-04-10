//
//  PostManager.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import Foundation
import SwiftUI
import OrderedCollections

/// The `DispatchQueue` to use when loading elements
public let loadQueue: DispatchQueue = .init(label: "sg.edu.sst.panziyue.Announcer.getPosts")

/// The enumeration that manages fetching and saving``Post``s
public enum PostManager {
    // MARK: Getting/saving posts
    /// Fetches the posts for a given range
    public static func getPosts(range: Range<Int>) -> [Post] {
        var effectiveRange = range.lowerBound..<range.lowerBound
        var posts: [Post] = getPinnedPosts(for: range, effectiveRange: &effectiveRange)

        do {
            let values = try fetchValues(range: effectiveRange.lowerBound..<range.upperBound)
            posts.append(contentsOf: filterOutPinnedPosts(from: values))
            loadQueue.async {
                addPostsToStorage(newItems: values)
            }
        } catch {
            posts = getCachePosts(range: range)
        }

        return posts
    }

    /// Fetches the cached posts for a given range
    public static func getCachePosts(range: Range<Int>) -> [Post] {
        Log.info("could not get values. Attempting to use cache.")
        let storage = postStorage

        guard !storage.isEmpty,
                range.lowerBound >= 0 && range.upperBound > range.lowerBound else {
            Log.info("No items in cache or invalid range")
            return []
        }

        let values = storage.values
        let newUpper = min(range.upperBound, values.count)
        return Array(values[range.lowerBound..<newUpper])
    }

    /// Loads the cached posts, with a completion
    public static func loadCachePosts(range: Range<Int>, onCompletion: @escaping () -> Void = {}) throws {
        // Split it into groups of 150, as the RSS cannot load more than 150 posts at a time
        var posts: [Post] = []
        do {
            for index in 0..<Int(ceil(Double(range.count)/Double(150))) {
                let lowerbound = index * 150 + range.lowerBound
                let upperbound = min((index+1) * 150 + range.lowerBound, range.upperBound)
                let newPosts = try fetchValues(range: lowerbound..<upperbound)
                posts.append(contentsOf: newPosts)
            }
        } catch {
            // save the progress that was made
            loadQueue.async {
                addPostsToStorage(newItems: posts)
            }
            throw error
        }
        loadQueue.async {
            Log.info("Adding \(posts.count) posts to storage")
            addPostsToStorage(newItems: posts)
            onCompletion()
        }
    }

    /// Saves a post to localstorage. Effectively a form of cache. NOTE: Does not actually have functionality
    public static func savePost(post: Post) {
    }

    // MARK: Pinned posts
    static var pinnedPosts: Set<PostTitle> {
        get {
            if let posts = _pinnedPosts {
                return posts
            }

            // Retrieve from file
            if let posts = read([PostTitle].self, from: "pinnedPosts.json") {
                _readPosts = Set(posts)
                return Set(posts)
            }

            return .init()
        }
        set {
            _pinnedPosts = newValue
            loadQueue.async {
                // TODO: Reduce the frequency of this.
                // As the set gets larger, this will become a more and more expensive task to do.
                // save to file system
                write(Array(newValue), to: "pinnedPosts.json")
            }
        }
    }
    private static var _pinnedPosts: Set<PostTitle>?

    // MARK: Read posts
    static var readPosts: Set<PostTitle> {
        get {
            if let posts = _readPosts, !posts.isEmpty {
                return posts
            }

            // Retrieve from file
            if let posts = read([PostTitle].self, from: "readPosts.json") {
                _readPosts = Set(posts)
                return Set(posts)
            }

            print("Init.... somehow")
            return .init()
        }
        set {
            _readPosts = newValue
            loadQueue.async {
                // TODO: Reduce the frequency of this.
                // As the set gets larger, this will become a more and more expensive task to do.
                // save to file system
                write(Array(newValue), to: "readPosts.json")
                print("Write posts: \(newValue.map({ $0.title }).joined(separator: " - "))")
            }
        }
    }
    private static var _readPosts: Set<PostTitle>? {
        didSet {
            print("SET YAAAAA \(_readPosts?.count ?? -1)")
        }
    }

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
    /// The list of user categories
    public static var userCategories: [UserCategory] {
        // flatten user categories for posts
        let categories = userCategoriesForPosts
        return categories.flatMap({ $1 })
    }

    /// A dictionary mapping the categories to the posts
    public static var userCategoriesForPosts: [PostTitle: [UserCategory]] {
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

    /// A flat list of user categories
    public static var userCategoriesFlat: [UserCategory] {
        Array(Set(userCategoriesForPosts.values.flatMap({ $0 })))
    }

    /// The cache for the posts
    public static var postStorage: OrderedDictionary<PostTitle, Post> {
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
/// The short placeholder string
public let placeholderTextShort = "Lorem ipsum dolor sit amet"
/// The long placeholder string
public let placeholderTextLong = """
Dear Students,

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt \
ut labore et dolore magna aliqua. Turpis egestas pretium aenean pharetra. Orci eu lobortis.

elementum nibh tellus molestie. Vulputate dignissim suspendisse in est. Vel pharetra vel \
turpis nunc. Malesuada nunc vel risus commodo. Nisi vitae suscipit tellus mauris.

Posuere orbi leo urna molestie at elementum eu. Urna duis convallis convallis tellus. Urna molestie \
at elementum eu. Nunc sed blandit libero volutpat.
"""
