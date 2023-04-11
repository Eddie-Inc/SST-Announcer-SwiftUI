//
//  Post.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import Foundation
import UserNotifications

/**
 Contains attributes for each post such as date, content and title

 This struct is used to store Posts. The posts stored here will be used in the ReadAnnouncements and the
 PinnedAnnouncements for persistency. It is also used to present each post in the AnnouncementsViewController.
 */
public struct Post: Codable, Equatable, Identifiable {
    public var title: String
    public var authors: [String]?
    public var content: String // This content will be a HTML as a String
    public var date: Date
    public var blogUrl: String?

    public var categories: [String]
    public var userCategories: [UserCategory]? // optional so that it plays well with Codable

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
                func reminderNotifications(content_title: String, content_subtitle: String) {
                    
                    let currentDate = Date()
                        
                    let content = UNMutableNotificationContent()
                    content.title = content_title
                    content.subtitle = content_subtitle
                    content.sound = UNNotificationSound.default

                    // show this notification five seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminderDate.timeIntervalSince(currentDate), repeats: false)

                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
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
            !link.absoluteString.contains("bp.blogspot.com/") &&
            ( // check that it is https or http
                link.absoluteString.hasPrefix("https://") ||
                link.absoluteString.hasPrefix("http://")
            )
        }

        return links
    }

    public init(title: String,
                authors: [String]? = nil,
                content: String,
                date: Date,
                blogURL: String?,
                categories: [String]) {
        self.title = title
        self.authors = (authors?.isEmpty ?? true) ? nil : authors
        self.content = content
        self.date = date
        self.blogUrl = blogURL
        self.categories = categories

        self.pinned = false
        self.read = false
        self.userCategories = nil
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
