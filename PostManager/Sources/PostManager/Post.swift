//
//  Post.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import Foundation

/**
 Contains attributes for each post such as date, content and title

 This struct is used to store Posts. The posts stored here will be used in the ReadAnnouncements and the
 PinnedAnnouncements for persistency. It is also used to present each post in the AnnouncementsViewController.
 */
public struct Post: Codable, Equatable, Identifiable {
    public var title: String
    public var content: String // This content will be a HTML as a String
    public var date: Date

    public var pinned: Bool {
        didSet {
            var posts = PostManager.pinnedPosts
            if pinned {
                posts.insert(postTitle)
            } else {
                posts.remove(postTitle)
            }
            PostManager.pinnedPosts = posts
        }
    }
    public var read: Bool {
        didSet {
            var posts = PostManager.readPosts
            if read {
                posts.insert(postTitle)
            } else {
                posts.remove(postTitle)
            }
            PostManager.readPosts = posts
        }
    }
    public var reminderDate: Date? {
        didSet {
            var reminderDates = PostManager.reminderDates
            if let reminderDate {
                reminderDates[postTitle] = reminderDate
            } else {
                reminderDates.removeValue(forKey: postTitle)
            }
            PostManager.reminderDates = reminderDates
        }
    }

    public var id: String {
        postTitle.description
    }

    public var postTitle: PostTitle {
        PostTitle(date: date, title: title)
    }

    public var authors: [String]?

    public var categories: [String]
    public var userCategories: [UserCategory]? // optional so that it plays well with Codable

    public func getLinks() -> [URL] {
        // separate each link
        let items = content.components(separatedBy: "href=\"")
        // empty array for each link
        var links: [URL] = []
        // get list of links
        for item in items {
            var newItem = ""

            for character in item {
                if character != "\"" {
                    newItem += String(character)
                } else {
                    break
                }
            }

            if let url = URL(string: newItem) {
                links.append(url)
            }
        }
        // remove duplicate links from the array
        links.removeDuplicates()

        links = links.filter { (link) -> Bool in
            !link.absoluteString.contains("bp.blogspot.com/")
        }

        return links
    }

    // Examples:
    // - Title:    "Release of 2022 GCE O-Level Examination Results"
    // - Expected: "2023/01/release-of-2022-gce-o-level-examination.html"
    //
    // - Title:    "[S2/S3/S4] SLS Account - LOG-IN & Profile Update EXERCISE"
    // - Expected: "2023/01/s2s3s4-sls-account-log-in-profile.html"
    //
    // - Title:    "[S1] SLS Account - Log-in Exercise"
    // - Expected: "2023/01/s1-sls-account-log-in-exercise.html"
    //
    public func getBlogID(limit: Int = 40) -> String {
        // to store the link
        var returnLink = ""

        // gets and formats the title of the post as we need that to get the link
        let formatted = title.filter { (char) -> Bool in
            char.isLetter || char.isNumber || char.isWhitespace || char == "-"
        }.lowercased()
        let split = formatted.split(separator: " ")

        for item in split {
            guard !item.isEmpty && item != "-" else { continue } // reject single dashes
            if returnLink.count + item.count < limit { // limit number of characters
                returnLink += item + "-"
            } else {
                break
            }
        }
        returnLink.removeLast() // remove the last dash

        return returnLink
    }

    public func getBlogURL(limit: Int = 40) -> URL {
        // we need to get the date to fetch the exact blog post
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "/yyyy/MM/"

        // generates the link of the blogpost
        let returnLink = blogURL + PostTitle(date: date, title: getBlogID(limit: limit)).description + ".html"

        let returnURL = URL(string: returnLink) ?? URL(string: blogURL)!

        // Checks if the URL is invalid
        let isURLValid: Bool = {
            let str = try? String(contentsOf: returnURL)
            if let str = str {
                return !str.contains("Sorry, the page you were looking for in this blog does not exist.")
            } else {
                return false
            }
        }()

        if isURLValid {
            Log.info("URL is valid: \(returnURL.description)")
            return returnURL
        }

        Log.info("URL is invalid: \(returnURL.description). Defaulting to \(blogURL)")
        // try again but with a limit of 41
        if limit == 40 {
            return getBlogURL(limit: 41)
        } else {
            // avoid infinite recursion
            return URL(string: blogURL)!
        }
    }

    public init(title: String,
                authors: [String]? = nil,
                content: String,
                date: Date,
                pinned: Bool,
                read: Bool,
                reminderDate: Date? = nil,
                categories: [String],
                userCategories: [UserCategory]? = nil) {
        self.title = title
        self.authors = (authors?.isEmpty ?? true) ? nil : authors
        self.content = content
        self.date = date
        self.pinned = pinned
        self.read = read
        self.reminderDate = reminderDate
        self.categories = categories
        self.userCategories = userCategories
    }
}

public struct PostTitle: CustomStringConvertible, Codable, Hashable {
    public var description: String {
        // we need to get the date to fetch the exact blog post
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "/yyyy/MM/"

        return dateFormatter.string(from: date) + title
    }
    public var date: Date
    public var title: String

    public init(date: Date, title: String) {
        self.date = date
        self.title = title
    }
}

public extension Array where Element: Hashable {
    /// Returns an array by removing duplicates from this array
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    /// Removes duplicates from this array
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
