//
//  Post.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import Foundation
import MarkdownUI

/**
 Contains attributes for each post such as date, content and title

 This struct is used to store Posts. The posts stored here will be used in the ReadAnnouncements and the
 PinnedAnnouncements for persistency. It is also used to present each post in the AnnouncementsViewController.
 */
struct Post: Codable, Equatable {
    var title: String
    var content: String // This content will be a HTML as a String
    var date: Date

    var pinned: Bool
    var read: Bool
    var reminderDate: Date?

    var categories: [String]
    var userCategories: [UserCategory]? // optional so that it plays well with Codable

    func getLinks() -> [URL] {
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

    func getBlogURL() -> URL {
        // we need to get the date to fetch the exact blog post
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "/yyyy/MM/"

        // to store the link
        var returnLink = ""

        // gets and formats the title of the post as we need that to get the link
        let formatted = title.filter { (a) -> Bool in
            a.isLetter || a.isNumber || a.isWhitespace
        }.lowercased()
        let split = formatted.split(separator: " ")

        for i in split {
            if returnLink.count + i.count < 40 {
                returnLink += i + "-"
            } else {
                break
            }
        }
        returnLink.removeLast()

        // generates the link of the blogpost
        returnLink = blogURL + dateFormatter.string(from: date) + returnLink + ".html"

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
            return returnURL
        }

        return URL(string: blogURL)!
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
